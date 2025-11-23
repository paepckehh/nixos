# webarchiv, archiv, archive, wayback, bookmark
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.webarchiv.ip} ${infra.webarchiv.hostname} ${infra.webarchiv.fqdn}";

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      readeck = {
        file = ../../modules/resources/readeck.age;
        owner = "readeck";
        group = "readeck";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.readeck = {};
    users = {
      readeck = {
        group = "readeck";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.readeck = {
    after = ["socket.target"];
    wants = ["socket.target"];
    wantedBy = ["multi-user.target"];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    readeck = {
      enable = true;
      environmentFile = config.age.secrets.readeck.path; # secret env vars format
      settings = {
        database.source = "sqlite3:/var/lib/readeck/db.sqlite";
        main = {
          log_level = "info";
          data_directory = "/var/lib/readeck";
        };
        server = {
          host = infra.localhost.ip;
          port = infra.webarchiv.localbind.port.http;
          trusted_proxies = [infra.localhost.cidr];
          base_url = infra.webarchiv.url;
        };
        email = {
          host = infra.smtp.admin.fqdn;
          port = infra.port.smtp;
          insecure = true;
          from = infra.admin.email;
          from_noreply = infra.admin.email;
        };
      };
    };
    caddy = {
      virtualHosts."${infra.webarchiv.fqdn}" = {
        listenAddresses = [infra.webarchiv.ip];
        extraConfig = ''import intraproxy ${toString infra.webarchiv.localbind.port.http}'';
      };
    };
  };
}
