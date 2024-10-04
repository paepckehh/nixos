{
  config,
  pkgs,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy = {
      enable = true;
      dataDir = "/var/www";
      virtualHosts = {
        "pki.paepcke.de".listenAddresses = ["127.0.0.1:8282"];
        "portal.paepcke.de".listenAddresses = ["127.0.0.1:9292"];
      };
    };
  };
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [8282 9292];
    };
  };
}
