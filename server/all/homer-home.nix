# PORTAL => HOMER: web gui portal
# icons [see res.nix] caddy file_server hosted icons via res.${infra.domain.user}/icons cc_source https://github.com/homarr-labs/dashboard-icons
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
  networking.extraHosts = "${infra.portal.ip} ${infra.portal.hostname} ${infra.portal.fqdn}.";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.portal.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.portal.fqdn}" = {
      listenAddresses = [infra.portal.ip];
      extraConfig = ''import intraproxy ${toString infra.portal.localbind.port.http}'';
    };
  };

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers.${infra.portal.name} = {
    autoStart = true;
    privateNetwork = false;
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      #################
      #-=# IMPORTS #=-#
      #################
      imports = [../../client/env.nix];

      ####################
      #-=# NETWORKING #=-#
      ####################
      networking.hostName = infra.portal.hostname;

      ##################
      #-=# SERVICES #=-#
      ##################
      services = {
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
        homer = {
          enable = true;
          virtualHost = {
            nginx.enable = true;
            domain = infra.portal.fqdn;
          };
          settings = {
            title = " ⛅HomeCloud ";
            subtitle = " ==> Start Portal internal HomeCloud!";
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
                    name = "Anmeldung [Authelia]";
                    tag = "app";
                    target = "_blank";
                    url = infra.sso.url;
                    logo = infra.sso.logo;
                  }
                  {
                    name = "NextCloud";
                    tag = "app";
                    target = "_blank";
                    url = infra.nextcloud.url;
                    logo = infra.nextcloud.logo;
                  }
                  {
                    name = "KI-Assistent";
                    tag = "app";
                    target = "_blank";
                    url = infra.ai.url;
                    logo = infra.ai.logo;
                  }
                  {
                    name = "Paperless-NGX";
                    tag = "app";
                    target = "_blank";
                    url = infra.paperless.url;
                    logo = infra.paperless.logo;
                  }
                  {
                    name = "WebArchiv [Readeck]";
                    tag = "app";
                    target = "_blank";
                    url = infra.webarchiv.url;
                    logo = infra.webarchiv.logo;
                  }
                  {
                    name = "Suche [SearX]";
                    tag = "app";
                    target = "_blank";
                    url = infra.search.url;
                    logo = infra.search.logo;
                  }
                  {
                    name = "Password Safe [Vaultwarden]";
                    tag = "app";
                    target = "_blank";
                    url = infra.vault.url;
                    logo = infra.vault.logo;
                  }
                  {
                    name = "Benutzer- und Passwordverwaltung [LLDAP]";
                    tag = "app";
                    target = "_blank";
                    url = infra.iam.url;
                    logo = infra.iam.logo;
                  }
                  {
                    name = "Druck-Aufträge Verwalten [CUPS]";
                    tag = "app";
                    target = "_blank";
                    url = infra.print.url;
                    logo = infra.print.logo;
                  }
                  {
                    name = "IT Status [KUMA]";
                    tag = "app";
                    target = "_blank";
                    url = infra.status.url;
                    logo = infra.status.logo;
                  }
                  {
                    name = "IT WikiPedia [Wikipedia]";
                    tag = "app";
                    target = "_blank";
                    url = infra.wiki.url;
                    logo = infra.wiki.logo;
                  }
                  {
                    name = "Web Resources [Caddy]";
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
                    name = "Wiki";
                    tag = "app";
                    target = "_blank";
                    url = infra.wiki-go.url;
                    logo = infra.wiki-go.logo;
                  }
                  {
                    name = "Glance";
                    tag = "app";
                    target = "_blank";
                    url = infra.glance.url;
                    logo = infra.glance.logo;
                  }
                  {
                    name = infra.meshtastic-web.app;
                    tag = "app";
                    target = "_blank";
                    url = infra.meshtastic-web.url;
                    logo = infra.meshtastic-web.logo;
                  }
                  {
                    name = "DNS Status [Adguard] ";
                    tag = "app";
                    target = "_blank";
                    url = infra.adguard.url;
                    logo = infra.adguard.logo;
                  }
                  {
                    name = "Bildverwaltung [Immich]";
                    tag = "app";
                    target = "_blank";
                    url = infra.immich.url;
                    logo = infra.immich.logo;
                  }
                  {
                    name = "Bildverwaltung [Ente]";
                    tag = "app";
                    target = "_blank";
                    url = infra.ente.url;
                    logo = infra.ente.logo;
                  }
                  {
                    name = "Musik Stream [Navidrome]";
                    tag = "app";
                    target = "_blank";
                    url = infra.navidrome.url;
                    logo = infra.navidrome.logo;
                  }
                  {
                    name = "RSS Reader [Miniflux]";
                    tag = "app";
                    target = "_blank";
                    url = infra.miniflux.url;
                    logo = infra.miniflux.logo;
                  }
                  {
                    name = "TimeTracker [Kimai]";
                    tag = "app";
                    target = "_blank";
                    url = infra.kimai.url;
                    logo = infra.kimai.logo;
                  }
                  {
                    name = "Proxmox [VM]";
                    tag = "app";
                    target = "_blank";
                    url = infra.proxmox.url;
                    logo = infra.proxmox.logo;
                  }
                  {
                    name = "Office [OnlyOffice-Cloud]";
                    tag = "app";
                    target = "_blank";
                    url = infra.onlyoffice.url;
                    logo = infra.onlyoffice.logo;
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
                    name = "Rackula";
                    tag = "app";
                    target = "_blank";
                    url = infra.rackula.url;
                    logo = infra.rackula.logo;
                  }
                  {
                    name = "BentoPDF";
                    tag = "app";
                    target = "_blank";
                    url = infra.bentopdf.url;
                    logo = infra.bentopdf.logo;
                  }
                  {
                    name = "DataBaseMent";
                    tag = "app";
                    target = "_blank";
                    url = infra.databasement.url;
                    logo = infra.databasement.logo;
                  }
                  {
                    name = "JellyFin";
                    tag = "app";
                    target = "_blank";
                    url = infra.jellyfin.url;
                    logo = infra.jellyfin.logo;
                  }
                  {
                    name = "ERPnext";
                    tag = "app";
                    target = "_blank";
                    url = infra.erpnext.url;
                    logo = infra.erpnext.logo;
                  }
                  {
                    name = "Web-Check";
                    tag = "app";
                    target = "_blank";
                    url = infra.web-check.url;
                    logo = infra.web-check.logo;
                  }
                  {
                    name = "WebSurfx";
                    tag = "app";
                    target = "_blank";
                    url = infra.websurfx.url;
                    logo = infra.websurfx.logo;
                  }
                  {
                    name = "Networking-Toolbox";
                    tag = "app";
                    target = "_blank";
                    url = infra.networking-toolbox.url;
                    logo = infra.networking-toolbox.logo;
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
      };
    };
  };
}
