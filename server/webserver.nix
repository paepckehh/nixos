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
        "pki.paepcke.de".listenAddresses = [":8282"];
        "portal.paepcke.de".listenAddresses = [":9292"];
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
