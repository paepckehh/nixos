{
  config,
  pkgs,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedUDPPorts = [53 67 68 123 3478 5514 1900 10001];
      allowedUDPPortRanges = [
        {
          from = 5656;
          to = 5699;
        }
      ];
      allowedTCPPorts = [53 8080 443 8443 8843 6789 27117];
    };
  };

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
          enable = false;
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
  };
}
