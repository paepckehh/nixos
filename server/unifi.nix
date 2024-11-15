{
  config,
  pkgs,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    unifi = {
      enable = true;
      openFirewall = true;
    };
    prometheus = {
      exporters = {
        unpoller = {
          enable = ;
          controllers = [
            {
              url = "http://localhost:8443";
              user = "readonly";
              pass = "/etc/nixos/server/resources/unifi.txt";
            }
          ];
        };
      };
    };
    static-web-server = {
      enable = false;
      listen = "10.0.0.30:9090";
      root = "/var/www";
      configuration = {
        general = {
          directory-listing = true;
        };
      };
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedUDPPorts = [];
      allowedTCPPorts = [9090];
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.tmpfiles.rules = [
    "d /var/www 0755 root users"
  ];
}
