{
  config,
  pkgs,
  ...
}: {
  #################
  #-=# SYSTEMD #=-#
  #################
  # ensure dns server record 192.168.80.200 -> readeck.lan
  systemd.network.networks."10-lan".addresses = [{Address = "192.168.80.200/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [80];
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    readeck = {
      enable = true;
      environmentFile = null;
      settings = {
        main = {
          log_level = "debug";
          secret_key = "start";
          data_directory = "/var/lib/readeck";
        };
        server = {
          host = "192.168.80.200";
          port = 80;
        };
        database = {
          source = "sqlite3:/var/lib/readeck/db.sqlite";
        };
      };
    };
  };
}
