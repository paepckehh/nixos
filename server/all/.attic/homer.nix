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
            items = [];
          }
          {
            name = "EXTERN";
            icon = "fas fa-bookmark";
            items = [];
          }
          {
            name = "IT Selfservice";
            icon = "fas fa-heartbeat";
            items = [];
          }
          {
            name = "TOOLS";
            icon = "fas fa-screwdriver-wrench";
            items = [];
          }
          {
            name = "INFO";
            icon = "fas fa-circle-info";
            items = [];
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
        respond @not_intranet 403
      '';
    };
  };
}
