{
  pkgs,
  lib,
  config,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        nextcloud = {
          ip = "192.168.80.206";
          hostname = "cloud";
          ports.tcp = 443;
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.nextcloud.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.nextcloud.ip} ${infra.lan.services.nextcloud.hostname} ${infra.lan.services.nextcloud.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.nextcloud.ports.tcp];
  };

  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    nextcloud-admin = {
      file = ../../modules/resources/nextcloud-admin.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.acme = {
    acceptTerms = true;
    certs."${config.services.nextcloud.hostName}" = {
      email = "pki@pki.lan";
      server = "https://pki.lan/acme/acme/directory";
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    nginx.virtualHosts."${config.services.nextcloud.hostName}" = {
      forceSSL = true;
      enableACME = true;
      listen = [
        {
          addr = "${infra.lan.services.nextcloud.ip}";
        }
      ];
    };
    nextcloud = {
      enable = true;
      configureRedis = true;
      database.createLocally = true;
      hostName = "${infra.lan.services.nextcloud.hostname}.${infra.lan.domain}";
      config = {
        adminpassFile = config.age.secrets.nextcloud-admin.path;
        adminuser = "admin";
        dbtype = "sqlite";
      };
      # settings = {
      #  auto_logout = "true";
      #  default_language = "de";
      #  default_locale = "en_DE";
      #  default_phone_region = "DE";
      #  default_timezone = "Europe/Berlin";
      #  remember_login_cookie_lifetime = "60*60*24*10"; # 10 Tage
      #  session_lifetime = "60*60*10"; # 10 Stunden
      #  session_keepalive = "false";
      # };
    };
  };
}
