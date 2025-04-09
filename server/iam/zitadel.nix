{
  pkgs,
  config,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../../modules/agenix.nix
  ];

  #############
  #-=# AGE #=-#
  #############
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
        CREATE USER dbadm_zitadel WITH PASSWORD 'zitadel';
        ALTER USER dbadm_zitadel WITH PASSWORD 'zitadel';
        ALTER USER dbadm_zitadel WITH CREATEDB;
        ALTER USER dbadm_zitadel WITH LOGIN;
        ALTER USER dbadm_zitadel WITH SUPERUSER;
      '';
    };
    zitadel = {
      enable = true;
      tlsMode = "enabled"; # enabled, external, disabled
      openFirewall = true;
      masterKeyFile = config.age.secrets.zitadel-key.path;
      settings = {
        Port = 8181;
        ExternalDomain = "zitadel.lan";
        Database.postgres = {
          Host = "127.0.0.1";
          Port = "${toString config.services.postgresql.settings.port}";
          Database = "zitadel";
          MaxOpenConns = "25";
          MaxConnLifetime = "1h";
          MaxConnIdleTime = "5m";
          Admin = {
            Username = "dbadm_zitadel";
            Password = "zitadel";
            SSL.Mode = "disable";
          };
        };
        TLS = {
          KeyPath = config.age.secrets.zitadel-tls-key.path;
          Cert = ''
            -----BEGIN CERTIFICATE-----
            MIIBpTCCAVegAwIBAgIUNUEJKRKIrLl4ngFFVK5G1Dr7u/0wBQYDK2VwMDMxETAP
            BgNVBAMMCGhvbWUubGFuMQswCQYDVQQGEwJVUzERMA8GA1UECgwIaG9tZS5sYW4w
            HhcNMjUwNDA5MDYyODQ2WhcNMzUwNDA3MDYyODQ2WjAzMREwDwYDVQQDDAhob21l
            LmxhbjELMAkGA1UEBhMCVVMxETAPBgNVBAoMCGhvbWUubGFuMCowBQYDK2VwAyEA
            HGDIyGlNqsHAKuNosA1Lv9ocPmFZ5KTWUGv4lil5xvyjfTB7MB0GA1UdDgQWBBQv
            W0B6NTMl43GIUCgaFJedYr25mzAfBgNVHSMEGDAWgBQvW0B6NTMl43GIUCgaFJed
            Yr25mzAPBgNVHRMBAf8EBTADAQH/MCgGA1UdEQQhMB+CC3ppdGFkZWwubGFuhwR/
            AAABhwTAqAhkhwTAqABkMAUGAytlcANBABlrjM2K3wJq33+6JDP6/Ucd80+i0svt
            kY1mRELlJdEvsKfUrHIk+z39zltwsyzJj8UEi91iruJj2LxnnqBKfgE=
            -----END CERTIFICATE-----
          '';
        };
      };
    };
  };
}
