{
  lib,
  config,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy = {
      enable = true;
      virtualHosts."read.lan" = {
        listenAddresses = ["192.168.80.200"];
        extraConfig = ''reverse_proxy http://127.0.0.1:8686'';
      };
    };
    readeck = {
      enable = true;
      environmentFile = null;
      settings = {
        main = {
          log_level = "debug";
          secret_key = "u2iZ9jsvJlHa7ADMebw6CnTpZKDn9J0g";
          data_directory = "/var/lib/readeck";
        };
        server = {
          host = "127.0.0.1";
          port = 8686;
        };
        database = {
          source = "sqlite3:/var/lib/readeck/db.sqlite";
        };
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."10-lan".addresses = [{Address = "192.168.80.200/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "192.168.80.200 read read.lan"; # ensure corresponding dns records
    firewall.allowedTCPPorts = [443];
  };
}
