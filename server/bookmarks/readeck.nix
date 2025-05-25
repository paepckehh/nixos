{
  config,
  pkgs,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [];
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
          host = "127.0.0.1";
          port = 8000;
        };
        database = {
          source = "sqlite3:/var/lib/readeck.sqlite";
        };
      };
    };
  };
}
