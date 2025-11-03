{
  pkgs,
  config,
  ...
}: {
  ##############
  #-=# INFO #=-#
  ##############
  # default webui login    => https://zitadel.lan:8080
  # default webui console  => https://zitadel.lan:8080/ui/console
  # default webui debuglog => https://zitadel.lan:8080/debug/healthz

  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../../modules/agenix.nix
  ];

  #############
  #-=# AGE #=-#
  #############
  # see resources/gencert.sh
  age = {
    secrets = {
      zitadel-key = {
        file = ../../modules/resources/zitadel-key.age;
        owner = "zitadel";
        group = "zitadel";
      };
      zitadel-tls-key = {
        file = ../../modules/resources/zitadel-tls-key.age;
        owner = "zitadel";
        group = "zitadel";
      };
      zitadel-tls-cert = {
        file = ../../modules/resources/zitadel-tls-cert.age;
        owner = "zitadel";
        group = "zitadel";
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [zitadel-tools];

  ##############
  # NETWORKING #
  ##############
  networking.extraHosts = ''127.0.0.1 zitadel.lan zitadel'';

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    postgresql = {
      enable = true;
      enableTCPIP = true;
      package = pkgs.postgresql_17;
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE USER zitadel WITH PASSWORD 'zitadel';
        ALTER USER zitadel WITH PASSWORD 'zitadel';
        ALTER USER zitadel WITH CREATEDB;
        ALTER USER zitadel WITH LOGIN;
        ALTER USER zitadel WITH SUPERUSER;
      '';
    };
    zitadel = {
      enable = true;
      tlsMode = "enabled"; # enabled, external, disabled
      openFirewall = true;
      masterKeyFile = config.age.secrets.zitadel-key.path;
      settings = {
        Port = 8080;
        ExternalDomain = "zitadel.lan";
        FirstInstance.Org.Human = {
          Username = "admin";
          Password = "start";
        };
        TLS = {
          CertPath = config.age.secrets.zitadel-tls-cert.path;
          KeyPath = config.age.secrets.zitadel-tls-key.path;
        };
        Database.postgres = {
          Host = "127.0.0.1";
          Port = "${toString config.services.postgresql.settings.port}";
          Database = "zitadel";
          MaxOpenConns = "25";
          MaxConnLifetime = "1h";
          MaxConnIdleTime = "5m";
          Admin = {
            Username = "zitadel";
            Password = "zitadel";
            SSL.Mode = "disable";
          };
          User = {
            Username = "zitadel";
            Password = "zitadel";
            SSL.Mode = "disable";
          };
        };
      };
    };
  };
}
