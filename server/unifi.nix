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
      # unifiPackage = pkgs.unifi8;
      # mongodbPackage = pkgs.mongodb-6_0;
    };
    prometheus = {
      exporters = {
        unpoller = {
          enable = false;
          controllers = [
            {
              url = "https://iss.admin.lan";
              user = "read-only-account";
              pass = /etc/nixos/server/resources/unifi.txt;
            }
          ];
        };
      };
    };
    static-web-server = {
      enable = false;
      listen = ":9090";
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
