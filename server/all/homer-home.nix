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
            items = [
              {
                name = "Anmeldung Single-Sign-On [Authelia]";
                tag = "app";
                target = "_blank";
                url = infra.sso.url;
                logo = infra.sso.logo;
              }
              {
                name = "NextCloud";
                tag = "app";
                target = "_blank";
                url = infra.cloud.url;
                logo = infra.cloud.logo;
              }
              {
                name = "KI-Assistent";
                tag = "app";
                target = "_blank";
                url = infra.ai.url;
                logo = infra.ai.logo;
              }
              {
                name = "Paperless-ngx";
                tag = "app";
                target = "_blank";
                url = infra.paperless.url;
                logo = infra.paperless.logo;
              }
              {
                name = "WebArchiv";
                tag = "app";
                target = "_blank";
                url = infra.webarchiv.url;
                logo = infra.webarchiv.logo;
              }
              {
                name = "Suche";
                tag = "app";
                target = "_blank";
                url = infra.search.url;
                logo = infra.search.logo;
              }
              {
                name = "Password Safe";
                tag = "app";
                target = "_blank";
                url = infra.vault.url;
                logo = infra.vault.logo;
              }
              {
                name = "Benutzer- und Passwordverwaltung";
                tag = "app";
                target = "_blank";
                url = infra.iam.url;
                logo = infra.iam.logo;
              }
              {
                name = "Druck-Aufträge Verwalten";
                tag = "app";
                target = "_blank";
                url = infra.print.url;
                logo = infra.print.logo;
              }
              {
                name = "IT Status";
                tag = "app";
                target = "_blank";
                url = infra.status.url;
                logo = infra.status.logo;
              }
              {
                name = "IT WikiPedia";
                tag = "app";
                target = "_blank";
                url = infra.wiki.url;
                logo = infra.wiki.logo;
              }
              {
                name = "Web Resources (Caddy)";
                tag = "app";
                target = "_blank";
                url = infra.res.url;
                logo = infra.res.logo;
              }
              {
                name = "Test";
                tag = "app";
                target = "_blank";
                url = infra.test.url;
                logo = infra.test.logo;
              }
              {
                name = "Adguard";
                tag = "app";
                target = "_blank";
                url = infra.adguard.url;
                logo = infra.adguard.logo;
              }
              {
                name = "WebACME";
                tag = "app";
                target = "_blank";
                url = infra.webacme.url;
                logo = infra.webacme.logo;
              }
              {
                name = "WebPKI";
                tag = "app";
                target = "_blank";
                url = infra.webpki.url;
                logo = infra.webpki.logo;
              }
              {
                name = "WebMTLS";
                tag = "app";
                target = "_blank";
                url = infra.webmtls.url;
                logo = infra.webmtls.logo;
              }
              {
                name = "Freifunk Status";
                tag = "external web";
                target = "_blank";
                logo = "${infra.res.url}/icon/png/openwrt.png";
                url = "https://map.luebeck.freifunk.net/#!v:m;n:60beb4236e6b";
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
      extraConfig = ''import intraproxy ${toString infra.portal.localbind.port.http}'';
    };
  };
}
