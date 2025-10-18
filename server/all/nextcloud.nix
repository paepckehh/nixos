{
  config,
  pkgs,
  ...
}: let
  infra = {
    admin = "admin";
    contact = "it@${infra.smtp.maildomain}";
    localhost = "127.0.0.1";
    localhostPortOffset = 7000;
    id = {
      admin = 0;
      user = 6;
    };
    port = {
      smtp = 25;
      http = 80;
      https = 443;
      webapp = [infra.port.http infra.port.https];
    };
    domain = {
      tld = "corp";
      admin = "adm.${infra.domain.tld}";
      user = "dbt.${infra.domain.tld}";
    };
    cidr = {
      admin = "${infra.net.user}.0/24";
      user = "${infra.net.user}.0/23";
    };
    net = {
      prefix = "10.20";
      admin = "${infra.net.prefix}.${toString infra.id.admin}";
      user = "${infra.net.prefix}.${toString infra.id.user}";
    };
    namespace = {
      admin = "${toString infra.id.admin}";
      user = "${toString infra.id.user}";
    };
    pki = {
      acmeContact = "acme@${infra.pki.fqdn}";
      caFile = "/etc/ca.crt";
      hostname = "pki";
      domain = infra.domain.admin;
      maildomain = "debitor.de";
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      url = "https://${infra.pki.fqdn}/acme/acme/directory";
    };
    smtp = {
      hostname = "smtp";
      domain = infra.domain.admin;
      fqdn = "${infra.smtp.hostname}.${infra.smtp.domain}";
      maildomain = "debitor.de";
    };
    ldap = {
      uri = "http://10.20.0.126:3890";
      base = "dc=dbt,dc=corp";
      bind.dn = "cn=bind,ou=persons,${infra.ldap.base}";
    };
    nextcloud = {
      id = 135;
      name = "nc";
      hostname = infra.nextcloud.name;
      domain = infra.domain.user;
      fqdn = "${infra.nextcloud.hostname}.${infra.nextcloud.domain}";
      ip = "${infra.net.user}.${toString infra.nextcloud.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost;
        port.http = infra.localhostPortOffset + infra.nextcloud.id;
      };
    };
  };
in {
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
  #-=# SERVICES #=-#
  ##################
  services = {
    nextcloud = {
      enable = true;
      configureRedis = true;
      # hostName = "${infra.nextcloud.fqdn}";
      hostName = "localhost";
      database.createLocally = true;
      extraAppsEnable = true;
      config = {
        adminpassFile = config.age.secrets.nextcloud-admin.path;
        adminuser = "admin";
        dbtype = "mysql";
      };
      # TODO XXX tables mail
      extraApps = {
        inherit
          (config.services.nextcloud.package.packages.apps)
          bookmarks
          calendar
          contacts
          cospend
          files_mindmap
          files_retention
          forms
          groupfolders
          integration_paperless
          maps
          news
          notes
          onlyoffice
          polls
          tasks
          twofactor_admin
          twofactor_webauthn
          whiteboard
          ;
      };
      settings = {
        auto_logout = "true";
        default_language = "de";
        default_locale = "en_DE";
        default_phone_region = "DE";
        default_timezone = "Europe/Berlin";
        remember_login_cookie_lifetime = "60*60*24*31"; # 31 Tage
        session_lifetime = "60*60*10"; # 10 Stunden
        session_keepalive = "false";
      };
    };
    # XXX fqdn!
    nginx.virtualHosts."${infra.nextcloud.hostname}" = {
      forceSSL = false;
      enableACME = false;
      listen = [
        {
          addr = infra.nextcloud.localbind.ip;
          port = infra.nextcloud.localbind.port.http;
        }
      ];
    };
    caddy = {
      enable = false; # XXX
      virtualHosts."${infra.nextcloud.fqdn}".extraConfig = ''
        bind ${infra.nextcloud.ip}
        reverse_proxy ${infra.nextcloud.localbind.ip}:${toString infra.nextcloud.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.nextcloud.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.nextcloud.name}.log
        }'';
    };
  };
}
