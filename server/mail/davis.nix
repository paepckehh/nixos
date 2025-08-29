{
  lib,
  pkgs,
  ...
}: let
  infra = {
    lan = {
      services = {
        caldav = {
          ip = "10.20.6.127";
          hostname = "cal";
          domain = "dbt.corp"
          email = "it@debitor.de";
          namespace = "06-dbt";
          network = "10.20.6.0/23";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7127;
          };
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.services.caldav.namespace}.addresses = [{Address = "${infra.lan.services.caldav.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.caldav.ip} ${infra.lan.services.caldav.hostname} ${infra.lan.services.caldav.hostname}.${infra.lan.services.caldav.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.caldav.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    davis = {
      enable = true;
    };
    caddy = {
      enable = false;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      virtualHosts."${infra.lan.services.caldav.hostname}.${infra.lan.services.caldav.domain}".extraConfig = ''
        bind ${infra.lan.services.caldav.ip}
        reverse_proxy ${infra.lan.services.caldav.localbind.ip}:${toString infra.lan.services.caldav.localbind.ports.tcp}
        tls pki@adm.corp {
              ca_root /etc/ca.crt
              ca https://pki.adm.corp/acme/acme/directory
        }
        @not_intranet {
          not remote_ip ${infra.lan.services.caldav.network}
        }
        respond @not_intranet 403
      '';
    };
  };
}
