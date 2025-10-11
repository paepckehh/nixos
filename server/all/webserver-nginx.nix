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
      defaultListen = [
        {
          addr = "127.0.0.1";
          ssl = false;
        }
      ];
      defaultHTTPListenPort = 8282;
      virtualHosts = {
        "/" = {root = "/var/www/catchall";};
        "pki.paepcke.de" = {root = "/var/www/pki.paepcke.de";};
        "it-portal.paepcke.de" = {root = "/var/www.it-portal.paepcke.de";};
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
