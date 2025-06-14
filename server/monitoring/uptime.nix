{...}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        status = {
          ip = "192.168.80.208";
          hostname = "status";
          ports.tcp = 8443;
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.status.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.status.ip} ${infra.lan.services.status.hostname} ${infra.lan.services.status.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.status.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    uptime-kuma = {
      enable = true;
      appriseSupport = false;
      settings = {
        UPTIME_KUMA_HOST = infra.lan.services.status.ip;
        UPTIME_KUMA_PORT = "${toString infra.lan.services.status.ports.tcp}";
      };
    };
  };
}
