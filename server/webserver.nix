{
  config,
  pkgs,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    static-web-server = {
      enable = true;
      path = "/var/www";
      listen = "0.0.0.0:8282";
      configuration = {
        general = {
          directory-listing = false;
        };
      };
    };
  };
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [80 443];
    };
  };
}
