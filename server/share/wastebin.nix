{...}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        wastebin = {
          ip = "192.168.80.207";
          hostname = "wastebin";
          ports.tcp = 80;
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.wastebin.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.wastebin.ip} ${infra.lan.services.wastebin.hostname} ${infra.lan.services.wastebin.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.wastebin.ports.tcp];
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
    wastebin = {
      enable = true;
      settings = {
        WASTEBIN_TITLE = "wastbin.lan";
        WASTEBIN_MAX_BODY_SIZE = 1024;
        WASTEBIN_HTTP_TIMEOUT = 5;
        WASTEBIN_BASEURL = "http://${infra.lan.services.wastebin.hostname}.${infra.lan.domain}";
        WASTEBIN_ADDRESS_PORT = "${infra.lan.services.wastebin.ip}:${toString infra.lan.services.wastebin.ports.tcp}";
        WASTEBIN_THEME = "coldark";
        RUST_LOG = "debug";
      };
    };
  };
}
