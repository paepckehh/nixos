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
  networking.extraHosts = "${infra.nocobase.ip} ${infra.nocobase.hostname} ${infra.nocobase.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.nocobase.ip}/32";}];
 
  #####################
  #-=# ENVIRONMENT #=-#
  #####################  
  environment.systemPackages = [ pkgs.mycli ];

  ##############
  #-=# USER #=-#
  ##############
  users = {
    users = {
      nocobase = {
        createHome = true;
        isNormalUser = false;
        isSystemUser = true;
        group = "nocobase";
        hashedPassword = lib.mkForce "$y$j9T$YMyUhScE6LiNjm4XIxHKp/$LZLms7WzjfyK3USuEX3MFf.NHcDDkXkJafZhY96Oaa4";  # XXX poc only, rage it
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.nocobase.fqdn}" = {
      listenAddresses = [infra.nocobase.ip];
      extraConfig = ''import intraproxy ${toString infra.nocobase.localbind.port.http}'';
    };
    mysql = {
      enable = true;
      package = pkgs.mariadb;
      ensureDatabases = [ "nocodb" ];
      ensureUsers = [
        {
          name = "nocodb";
          ensurePermissions."nocodb.*" = "ALL PRIVILEGES";
        }
      ];
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        nocobase = {
          image = "nocobase/nocobase:latest-full";
          ports = ["${infra.localhost.ip}:${toString infra.nocobase.localbind.port.http}:80"];
          volumes = ["/var/lib/nocodb:/app/nocobase/storage"];
          environment = {
            SET_SERVER_NAME = infra.nocobase.fqdn;
            TZ = infra.locale.tz;
            APP_KEY = "your-secret-key-BGFBsvdgsbgdBGsbgS"; # XXX poc only rage it
            DB_DIALECT = "mariadb";
            DB_HOST = "mariadb";
            DB_PORT = "3306";
            DB_DATABASE = "nocobase";
            DB_USER = "nocobase";
            DB_PASSWORD = "nocobase-FsD5549"; # XXX poc only, rage it
            DB_UNDERSCORED = true;
          };
        };
      };
    };
  };
}
