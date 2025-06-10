{
  lib,
  pkgs,
  config,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    whoogle-search = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 8787;
    };
    caddy = {
      enable = true;
      configFile = pkgs.writeText "CaddyfileWhoogle" ''
        whoogle.${config.networking.domain} {
          tls internal 
          reverse_proxy ${config.services.whoogle-search.listenAddress}:${toString config.services.whoogle-search.port}
          @not_intranet {
            not remote_ip 192.168.80.0/24
          }
          respond @not_intranet 403
        }'';
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."10-lan".addresses = [{Address = "192.168.80.202/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "192.168.80.201 search search.${config.networking.domain}";
    firewall.allowedTCPPorts = [443];
  };
}
