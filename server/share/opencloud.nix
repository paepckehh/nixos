{
  pkgs,
  config,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        opencloud = {
          ip = "192.168.80.206";
          hostname = "opencloud";
          ports.tcp = 443;
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.opencloud.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.opencloud.ip} ${infra.lan.services.opencloud.hostname} ${infra.lan.services.opencloud.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.opencloud.ports.tcp];
  };

  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    # systemPackages = with pkgs; [];
    shellAliases = {};
    variables = {};
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    opencloud = {
      enable = true;
      address = "${infra.lan.services.opencloud.ip}";
      port = infra.lan.services.opencloud.ports.tcp;
      environment = {
        OC_INSECURE = "true";
        OC_LOG_LEVEL = "info";
      };
    };
  };
}
