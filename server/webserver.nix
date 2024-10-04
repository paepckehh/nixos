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
      dataDir = "/var/www"
      virtualHosts = {
        "pki.paepcke.de".listenAddresses = "0.0.0.0:8282";
        "portal.paepcke.de".listenAddresses = "0.0.0.0:9292";

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
