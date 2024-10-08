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
      dataDir = "/var/www/catchall";
      globalConfig = ''
        auto_https off
        http_port 8282
      '';
      virtualHosts."portal.paepcke.de".extraConfig = ''root /var/www/portal.paepcke.de'';
      virtualHosts."pki.paepcke.de".extraConfig = ''root /var/www.pki.paepcke.de'';
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
