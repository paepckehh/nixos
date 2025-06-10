{config, ...}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        grafana = {
          enable = true;
          hostname = "grafana";
          ip = "192.168.80.211";
          ports.tcp = 443;
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.grafana.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.grafana.ip} ${infra.lan.services.grafana.hostname} ${infra.lan.services.grafana.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.grafana.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    grafana = {
      enable = infra.lan.services.grafana.enable;
      settings = {
        server = {
          http_addr = infra.lan.services.grafana.ip;
          http_port = infra.lan.services.grafana.ports.tcp;
          root_url = "https://${infra.lan.services.grafana.hostname}.${infra.lan.domain}:${toString infra.lan.services.grafana.ports.tcp}/";
          serve_from_sub_path = true;
        };
      };
    };
  };
}
