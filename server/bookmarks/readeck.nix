{config}: {
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

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."10-lan".addresses = [{Address = "${config.services.readeck.server.host}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${config.services.readeck.server.host} read read.lan"; # ensure corresponding dns records
    firewall.allowedTCPPorts = [config.services.readeck.settings.server.port];
  };
}
