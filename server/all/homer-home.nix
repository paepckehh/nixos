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
  infra = (import ../../siteconfig/config.nix).infra;
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
  # icons [see res.nix] caddy file_server hosted icons via res.${infra.domain.user}/icons cc_source https://github.com/homarr-labs/dashboard-icons
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
        # logo = "https://res.${infra.domain.user}/branding/debitor_icon_dark.png";
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
            <H3> -= 📣 NEWS =- </H3>
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
            name = "APPS";
            icon = "fas fa-cloud";
            items = [
              {
                name = "NextCloud";
                logo = "https://res.${infra.domain.user}/icon/png/nextcloud-blue.png";
                tag = "app";
                url = "https://cloud.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "KI-Assistenten";
                logo = "https://res.${infra.domain.user}/icon/png/ollama.png";
                tag = "app";
                url = "https://ai.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "Paperless";
                logo = "https://res.${infra.domain.user}/icon/png/paperless-ng.png";
                tag = "app";
                url = "https://paperless.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "WebArchiv";
                url = infra.webarchiv.url;
                logo = infra.webarchiv.logo;
                tag = "app";
                target = "_blank";
              }
              {
                name = "Suche";
                url = infra.search.url;
                logo = infra.search.logo;
                tag = "app";
                target = "_blank";
              }
              {
                name = "Password Safe";
                logo = "https://res.${infra.domain.user}/icon/png/bitwarden.png";
                tag = "debi app";
                url = "https://vault.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "Secret Share";
                logo = "https://res.${infra.domain.user}/icon/png/passwork.png";
                tag = "debi app";
                url = "https://secret.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "Matrix Web Messenger";
                logo = "https://res.${infra.domain.user}/icon/png/element.png";
                tag = "debi app";
                url = "https://matrix-web.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "Benutzer- und Passwordverwaltung";
                logo = "https://res.${infra.domain.user}/icon/png/nextcloud-contacts.png";
                tag = "debi it app";
                url = "https://iam.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "Anmeldung [Single Sign-on]";
                logo = "https://res.${infra.domain.user}/icon/png/authelia.png";
                tag = "debi it app";
                url = "https://sso.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "Drucker Aufträge Verwalten";
                logo = "https://res.${infra.domain.user}/icon/png/printer.png";
                tag = "debi it app";
                url = "https://drucker.${infra.domain.user}/printers";
                target = "_blank";
              }
              {
                name = "IT Status";
                logo = "https://res.${infra.domain.user}/icon/png/healthchecks.png";
                tag = "debi it app";
                url = "https://status.${infra.domain.user}/status/debitor";
                target = "_blank";
              }
              {
                name = "IT WikiPedia";
                logo = "https://res.${infra.domain.user}/icon/png/mediawiki.png";
                tag = "debi it app";
                url = "https://wiki.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "Freifunk Status";
                logo = "https://res.${infra.domain.user}/icon/png/openwrt.png";
                tag = "debi it app";
                url = "https://map.luebeck.freifunk.net/#!v:m;n:60beb4236e6b";
                target = "_blank";
              }
              {
                name = "PDF Cloud [Stirling]";
                logo = "https://res.${infra.domain.user}/icon/png/stirling-pdf.png";
                tag = "debi app";
                url = "https://pdf.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "Data Konverter Cloud [Chef]";
                logo = "https://res.${infra.domain.user}/icon/png/cyberchef.png";
                tag = "debi app";
                url = "https://chef.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "Code Cloud GIT [forgejo]";
                logo = "https://res.${infra.domain.user}/icon/png/forgejo.png";
                tag = "debi app";
                url = "https://git.${infra.domain.user}/explore/repos";
                target = "_blank";
              }
              {
                name = "Netzwerk Test Intern [OpenSpeedtest]";
                logo = "https://res.${infra.domain.user}/icon/png/openspeedtest.png";
                tag = "debi it app";
                url = "https://speed.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "WebACME";
                logo = "https://res.${infra.domain.user}/icon/png/cert-warden.png";
                tag = "debi it app";
                url = "https://webacme.${infra.domain.admin}";
                target = "_blank";
              }
              {
                name = "WebPKI";
                logo = "https://res.${infra.domain.user}/icon/png/cert-manager.png";
                tag = "debi it app";
                url = "https://webpki.${infra.domain.admin}";
                target = "_blank";
              }
              {
                name = "WebMTLS";
                logo = "https://res.${infra.domain.user}/icon/png/vault.png";
                tag = "debi it app";
                url = "https://webmtls.${infra.domain.admin}";
                target = "_blank";
              }
              {
                name = "Web Resources (Caddy)";
                logo = "https://res.${infra.domain.user}/icon/png/caddy.png";
                tag = "debi it app";
                url = "https://res.${infra.domain.user}";
                target = "_blank";
              }
              {
                name = "Test";
                logo = "https://res.${infra.domain.user}/icon/png/speedtest-tracker.png";
                tag = "debi it app";
                url = "https://test.${infra.domain.user}";
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
    caddy.virtualHosts."${infra.portal.fqdn}" = {
      listenAddresses = [infra.portal.ip];
      extraConfig = ''
        reverse_proxy ${infra.localhost.ip}:${toString infra.portal.localbind.port.http}
        @not_intranet { not remote_ip ${infra.portal.access.cidr} }
        respond @not_intranet 403'';
    };
  };
}
