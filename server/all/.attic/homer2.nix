# PORTAL => HOMER: web gui portal
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/home.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.portal.ip} ${infra.portal.hostname} ${infra.portal.fqdn}.";
    firewall.allowedTCPPorts = infra.port.webapps;
    firewall.allowedUDPPorts = [infra.port.http];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  # icons [see web/caddy-res.nix]
  # caddy file_server hosted icons via res.${infra.domain.user}/icons
  # cc_source https://github.com/homarr-labs/dashboard-icons
  services = {
    homer = {
      enable = true;
      virtualHost = {
        nginx.enable = true;
        domain = infra.portal.fqdn;
      };
      settings = {
        title = " ⛅Cloud ";
        subtitle = " ==> Start Portal interne Service Cloud!";
        # logo = "https://res.dbt.corp/branding/debitor_icon_dark.png";
        header = true;
        columns = "2";
        connectivityCheck = false;
        proxy.useCredentials = false;
        defaults = {
          layout = "list"; # columns list
          colorTheme = "auto";
        };
        theme = "neon"; # default classic neon walkxcode
        message = {
          style = "is-warning";
          title = "Sichere Internet Suche";
          icon = "fa fa-magnifying-glass";
          content = ''
            <form method="post" action="${infra.search.url}">
            <input type="text" name="q">
            <input type="hidden" name="lang" value="de">
            <input type="hidden" name="locale" value="de">
            <input type="submit" value="Search">
            </form><br><br>
            <table {border-spacing: 30px;}>
            <tr><th><H3> -= 📣 NEWS =- </H3></th></tr>
            <tr>
            <td>30.10.25 ab 15:30 Uhr</td>
            </tr><tr>
            <td>DSS Online Wartung.</td>
            </tr></table>
          '';
        };
        colors = {
          light = {
            text = "#1e4d8e";
            text-header = "#424242";
            text-title = "#555";
            text-subtitle = "#424242";
            card-shadow = "rgba(0, 0, 0, 0.8)";
            background = "#f4f6f8";
          };
          dark = {
            text = "#eaeaea";
            text-header = "#ffffff";
            text-title = "#fafafa";
            text-subtitle = "#f5f5f5";
            card-shadow = "rgba(0, 0, 0, 0.8)";
            background = "#131313";
          };
        };
        links = [];
        footer = "<p> 🤘 Einen erfolgreichen Arbeitstag wünscht euch euer IT Team 🤘 </p>";
        services = [
          {
            name = "INTERN";
            icon = "fas fa-cloud";
            items = [
              {
                # type = "Nextcloud";
                name = "NextCloud";
                logo = "https://res.dbt.corp/icon/png/nextcloud-blue.png";
                tag = "debi app";
                url = "https://cloud.dbt.corp";
                target = "_blank";
              }
              {
                name = "KI-Assistenten";
                logo = "https://res.dbt.corp/icon/png/ollama.png";
                tag = "debi app";
                url = "https://ai.dbt.corp";
                target = "_blank";
              }
              {
                name = "Paperless";
                logo = "https://res.dbt.corp/icon/png/paperless-ng.png";
                tag = "debi app";
                url = "https://paperless.dbt.corp";
                target = "_blank";
              }
              {
                name = "WebArchiv";
                logo = "https://res.dbt.corp/icon/png/readeck.png";
                tag = "debi app";
                url = "https://archive.dbt.corp";
                target = "_blank";
              }
              {
                name = "Suche";
                logo = "https://res.dbt.corp/icon/png/searxng.png";
                tag = "debi app";
                url = "https://suche.dbt.corp";
                target = "_blank";
              }
              {
                name = "Intracall Callcenter";
                logo = "https://res.dbt.corp/icon_cache/incas.png";
                tag = "debi app";
                url = "https://intracall.dbt.corp";
                target = "_blank";
              }
              {
                # type = "Vaultwarden";
                name = "Password Safe";
                logo = "https://res.dbt.corp/icon/png/bitwarden.png";
                tag = "debi app";
                url = "https://vault.dbt.corp";
                target = "_blank";
              }
              {
                name = "Secret Share";
                logo = "https://res.dbt.corp/icon/png/passwork.png";
                tag = "debi app";
                url = "https://secret.dbt.corp";
                target = "_blank";
              }
              {
                # type = "Matrix";
                name = "Matrix Web Messenger";
                logo = "https://res.dbt.corp/icon/png/element.png";
                tag = "debi app";
                url = "https://matrix-web.dbt.corp";
                target = "_blank";
              }
              {
                name = "Webmail [@debitor.de]";
                logo = "https://res.dbt.corp/icon/png/roundcube.png";
                tag = "debi app";
                url = "https://webmail.dbt.corp";
                target = "_blank";
              }
            ];
          }
          {
            name = "EXTERN";
            icon = "fas fa-bookmark";
            items = [
              {
                name = "Schufa Portal";
                logo = "https://res.dbt.corp/icon_cache/shufa.png";
                tag = "internet";
                url = "https://www.schufa.de";
                target = "_blank";
              }
              {
                name = "Nürnberger Versicherung";
                logo = "https://res.dbt.corp/icon_cache/nv.png";
                tag = "internet";
                url = "https://s2s.nuernberger.de/vpn/index.html";
                target = "_blank";
              }
              {
                name = "UserLike";
                logo = "https://res.dbt.corp/icon_cache/lime.png";
                tag = "internet";
                url = "https://connect.lime-technologies.com/de/";
                target = "_blank";
              }
              {
                name = "WhatsApp";
                logo = "https://res.dbt.corp/icon/png/whatsapp.png";
                tag = "internet";
                url = "https://app.messengerpeople.com/login";
                target = "_blank";
              }
            ];
          }
          {
            name = "IT Selfservice";
            icon = "fas fa-heartbeat";
            items = [
              {
                name = "Benutzer- und Passwordverwaltung";
                logo = "https://res.dbt.corp/icon/png/nextcloud-contacts.png";
                tag = "debi it app";
                url = "https://iam.dbt.corp";
                target = "_blank";
              }
              {
                name = "Anmeldung [Single Sign-on]";
                logo = "https://res.dbt.corp/icon/png/authelia.png";
                tag = "debi it app";
                url = "https://sso.dbt.corp";
                target = "_blank";
              }
              {
                name = "Drucker Aufträge Verwalten";
                logo = "https://res.dbt.corp/icon/png/printer.png";
                tag = "debi it app";
                url = "https://drucker.dbt.corp/printers";
                target = "_blank";
              }
              {
                # type = "UptimeKuma";
                name = "IT Status";
                logo = "https://res.dbt.corp/icon/png/healthchecks.png";
                tag = "debi it app";
                url = "https://status.dbt.corp/status/debitor";
                target = "_blank";
              }
              {
                name = "IT Tickets";
                logo = "https://res.dbt.corp/icon_cache/ticket.png";
                tag = "debi it app";
                url = "https://ticket.dbt.corp/";
                target = "_blank";
              }
              {
                name = "IT DSS Redmine Tickets";
                logo = "https://res.dbt.corp/icon_cache/dss.png";
                tag = "debi it app";
                url = "https://redmine.dbt.corp/redmine";
                target = "_blank";
              }
              {
                name = "IT DigiPedia";
                logo = "https://res.dbt.corp/icon/png/mediawiki.png";
                tag = "debi it app";
                url = "https://wiki.dbt.corp";
                target = "_blank";
              }
              {
                name = "Freifunk Status";
                logo = "https://res.dbt.corp/icon_cache/freifunk.png";
                tag = "debi it app";
                url = "https://map.luebeck.freifunk.net/#!v:m;n:60beb4236e6b";
                target = "_blank";
              }
            ];
          }
          {
            name = "TOOLS";
            icon = "fas fa-screwdriver-wrench";
            items = [
              {
                name = "PDF Cloud [Stirling]";
                logo = "https://res.dbt.corp/icon/png/stirling-pdf.png";
                tag = "debi app";
                url = "https://pdf.dbt.corp";
                target = "_blank";
              }
              {
                name = "Data Konverter Cloud [Chef]";
                logo = "https://res.dbt.corp/icon/png/cyberchef.png";
                tag = "debi app";
                url = "https://chef.dbt.corp";
                target = "_blank";
              }
              {
                name = "Code Cloud GIT [forgejo]";
                logo = "https://res.dbt.corp/icon/png/forgejo.png";
                tag = "debi app";
                url = "https://git.dbt.corp/explore/repos";
                target = "_blank";
              }
              {
                name = "Netzwerk Test Intern [OpenSpeedtest]";
                logo = "https://res.dbt.corp/icon/png/openspeedtest.png";
                tag = "debi it app";
                url = "https://speed.dbt.corp";
                target = "_blank";
              }
            ];
          }
          {
            name = "INFO";
            icon = "fas fa-circle-info";
            items = [
              {
                name = "Wetter";
                type = "OpenWeather";
                apikey = "90439e16168e7c42beb9c53f812ded1c";
                locationId = "2953347";
                units = "metric";
                background = "square";
                target = "_blank";
              }
            ];
          }
        ];
      };
    };
    nginx.virtualHosts."${infra.portal.fqdn}" = {
      forceSSL = false;
      enableACME = false;
      listen = [
        {
          addr = infra.localhost.ip;
          port = infra.portal.localbind.port.http;
        }
      ];
    };
    caddy = {
      enable = true;
      virtualHosts."${infra.portal.fqdn}".extraConfig = ''
        bind ${infra.portal.ip}
        reverse_proxy ${infra.localhost.ip}:${toString infra.portal.localbind.port.http}
        tls ${infra.pki.acme.contact} {
            ca_root ${infra.pki.certs.rootCA.path}
            ca ${infra.pki.acme.url}
        }
        @not_intranet {
            not remote_ip ${infra.portal.access.cidr}
        }
        respond @not_intranet 403
        log {
            output file ${config.services.caddy.logDir}/access/${infra.portal.name}.log
        }'';
    };
  };
}
