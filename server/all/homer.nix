{config, ...}: let
  infra = {
    admin = "admin";
    contact = "it@${infra.smtp.maildomain}";
    localhost = {
      ip = "127.0.0.1";
      port.offset = 7000;
    };
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
    portal = {
      id = 137;
      name = "start";
      hostname = infra.portal.name;
      domain = infra.domain.user;
      fqdn = "${infra.portal.hostname}.${infra.portal.domain}";
      ip = "${infra.net.user}.${toString infra.portal.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost.ip;
        port.http = infra.localhost.port.offset + infra.portal.id;
      };
    };
  };
in {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    homer = {
      enable = true;
      virtualHost = {
        nginx.enable = true;
        domain = "localhost";
      };
      settings = {
        title = "App dashboard";
        subtitle = "Homer";
        logo = "assets/logo.png";
        header = true;
        columns = "3";
        connectivityCheck = true;
        proxy = {
          useCredentials = false;
          headers = {
            Test = "Example";
            Test1 = "Example1";
          };
        };
        defaults = {
          layout = "columns";
          colorTheme = "auto";
        };
        theme = "default";
        message = {
          style = "is-warning";
          title = "Optional message!";
          icon = "fa fa-exclamation-triangle";
          content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.";
        };
        links = [
          {
            name = "Link 1";
            icon = "fab fa-github";
            url = "https://github.com/bastienwirtz/homer";
            target = "_blank";
          }
          {
            name = "link 2";
            icon = "fas fa-book";
            url = "https://github.com/bastienwirtz/homer";
          }
        ];
        services = [
          {
            name = "Application";
            icon = "fas fa-code-branch";
            items = [
              {
                name = "Awesome app";
                logo = "assets/tools/sample.png";
                subtitle = "Bookmark example";
                tag = "app";
                keywords = "self hosted reddit";
                url = "https://www.reddit.com/r/selfhosted/";
                target = "_blank";
              }
              {
                name = "Another one";
                logo = "assets/tools/sample2.png";
                subtitle = "Another application";
                tag = "app";
                tagstyle = "is-success";
                url = "#";
              }
            ];
          }
          {
            name = "Other group";
            icon = "fas fa-heartbeat";
            items = [
              {
                name = "Pi-hole";
                logo = "assets/tools/sample.png";
                tag = "other";
                url = "http://192.168.0.151/admin";
                type = "PiHole";
                target = "_blank";
              }
            ];
          }
        ];
      };
    };
    # XXX fqdn!
    nginx.virtualHosts."${infra.portal.hostname}" = {
      forceSSL = false;
      enableACME = false;
      listen = [
        {
          addr = infra.portal.localbind.ip;
          port = infra.portal.localbind.port.http;
        }
      ];
    };
    caddy = {
      enable = false; # XXX
      virtualHosts."${infra.portal.fqdn}".extraConfig = ''
        bind ${infra.portal.ip}
        reverse_proxy ${infra.portal.localbind.ip}:${toString infra.portal.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.portal.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.portal.name}.log
        }'';
    };
  };
}
