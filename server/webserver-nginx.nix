{
  config,
  pkgs,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    nginx = {
      enable = true;
      defaultListen = ["127.0.0.1"];
      defaultHTTPListenPort = 8282;
      virtualHosts = {
        "pki.paepcke.de" = {
          root = "/var/www/pki.paepcke.de"
        };
        "it-portal.paepcke.de" = {
          root = "/var/www.it-portal.paepcke.de"
        }; 
      };
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [8282];
    };
  };
}
