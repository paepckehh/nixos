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
  networking.extraHosts = "${infra.glance.ip} ${infra.glance.hostname} ${infra.glance.fqdn}.";

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    glance = {
      enable = true;
      settings = {
        server = {
          host = infra.localhost.ip;
          port = infra.glance.localbind.port.http;
        };
        # branding = {
        # logo-url: /assets/logo.png
        # favicon-url: /assets/logo.png
        # app-icon-url = "/assets/app-icon.png";
        # app-name = "IT Team Nerd News";
        # app-background-color = "#151519";
        # custom-footer = "<p>Moin!<a href=${infra.portal.url}>PORTAL HOME</a></p>";
        # };
        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "full";
                widgets = [
                  {
                    type = "rss";
                    style = "detailed-list";
                    limit = 125;
                    collapse-after = 6;
                    cache = "12h";
                    feeds = [
                      {
                        url = "https://feeds.feedburner.com/TheHackersNews?format=xml";
                        title = "hacker news";
                        limit = 25;
                      }
                      {
                        url = "https://www.schneier.com/tag/cybersecurity/";
                        title = "infosec schneier";
                        limit = 25;
                      }
                      {
                        url = "https://selfh.st/rss/";
                        title = "selfh.st";
                        limit = 25;
                      }
                      {
                        url = "https://www.linux-magazin.de/feed/";
                        title = "linux magazin";
                        limit = 25;
                      }
                      {
                        url = "https://www.bbk.bund.de/DE/Infothek/Unsere-Meldungen/RSSNewsfeed/_functions/rssnewsfeed-bbk.xml?nn=20130";
                        title = "Bundesamt für Bevölkerungsschutz";
                        limit = 25;
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    };
    caddy.virtualHosts."${infra.glance.fqdn}" = {
      listenAddresses = [infra.glance.ip];
      extraConfig = ''import intraproxy ${toString infra.glance.localbind.port.http}'';
    };
  };
}
