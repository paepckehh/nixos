#  it portal homer
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
    extraHosts = "${infra.it.ip} ${infra.it.hostname} ${infra.it.fqdn}.";
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
        domain = infra.it.fqdn;
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
                tag = "admin app";
                target = "_blank";
                url = infra.cloud.url;
                logo = infra.cloud.logo;
              }
              {
                name = "Kuma";
                tag = "admin app";
                target = "_blank";
                url = infra.monitoring.url;
                logo = infra.monitoring.logo;
              }
              {
                name = "cache";
                tag = "app";
                target = "_blank";
                url = infra.cache.url;
                logo = infra.cache.logo;
              }
            ];
          }
          {
            name = "OPNSENSE-HOT-STANDBY-POOL";
            icon = "fas fa-cloud";
            items = [
              {
                name = "${infra.opn.name}01";
                logo = infra.opn.logo;
                tag = "admin ${infra.opn.name}";
                url = "https://${infra.opn.name}01.${infra.domain.admin}:${infra.opn.adminport.https}";
                target = "_blank";
              }
            ];
          }
          {
            name = "OPNSENSE-INTRANET-BUILDER";
            icon = "fas fa-cloud";
            items = [
              {
                name = "${infra.opn.name}02";
                logo = infra.opn.logo;
                tag = "admin ${infra.opn.name}";
                url = "https://${infra.opn.name}02.${infra.domain.admin}:${infra.opn.adminport.https}";
                target = "_blank";
              }
              {
                name = "${infra.opn.name}03";
                logo = infra.opn.logo;
                tag = "admin ${infra.opn.name}";
                url = "https://${infra.opn.name}03.${infra.domain.admin}:${infra.opn.adminport.https}";
                target = "_blank";
              }
            ];
          }
          {
            name = "OPNSENSE-INTERNET-FIREWALL";
            icon = "fas fa-cloud";
            items = [
              {
                name = "${infra.opn.name}11";
                logo = infra.opn.logo;
                tag = "admin ${infra.opn.name}";
                url = "https://${infra.opn.name}11.${infra.domain.admin}:${infra.opn.adminport.https}";
                target = "_blank";
              }
              {
                name = "${infra.opn.name}12";
                logo = infra.opn.logo;
                tag = "admin ${infra.opn.name}";
                url = "https://${infra.opn.name}12.${infra.domain.admin}:${infra.opn.adminport.https}";
                target = "_blank";
              }
              {
                name = "${infra.opn.name}13";
                logo = infra.opn.logo;
                tag = "admin ${infra.opn.name}";
                url = "https://${infra.opn.name}13.${infra.domain.admin}:${infra.opn.adminport.https}";
                target = "_blank";
              }
            ];
          }
        ];
      };
    };
    nginx.virtualHosts."${infra.it.fqdn}" = {
      forceSSL = false;
      enableACME = false;
      listen = [
        {
          addr = infra.localhost.ip;
          port = infra.it.localbind.port.http;
        }
      ];
    };
    caddy.virtualHosts."${infra.it.fqdn}" = {
      listenAddresses = [infra.it.ip];
      extraConfig = ''
        reverse_proxy ${infra.localhost.ip}:${toString infra.it.localbind.port.http}
        @not_intranet { not remote_ip ${infra.it.access.cidr} }
        respond @not_intranet 403'';
    };
  };
}
