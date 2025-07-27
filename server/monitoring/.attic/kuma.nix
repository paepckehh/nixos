{
  config,
  lib,
  pkgs,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        kuma = {
          ip = "192.168.80.208";
          hostname = "kuma";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 9494;
          };
        };
        status = {
          ip = "192.168.80.209";
          hostname = "status";
          ports.tcp = 443;
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [
    {Address = "${infra.lan.services.kuma.ip}/32";}
    {Address = "${infra.lan.services.status.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "\n
    ${infra.lan.services.kuma.ip} ${infra.lan.services.kuma.hostname} ${infra.lan.services.kuma.hostname}.${infra.lan.domain}\n
    ${infra.lan.services.status.ip} ${infra.lan.services.status.hostname} ${infra.lan.services.status.hostname}.${infra.lan.domain}\n
    ";
    firewall.allowedTCPPorts = [infra.lan.services.status.ports.tcp infra.lan.services.kuma.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    uptime-kuma = {
      enable = true;
      appriseSupport = false;
      settings = {
        UPTIME_KUMA_HOST = infra.lan.services.kuma.localbind.ip;
        UPTIME_KUMA_PORT = "${toString infra.lan.services.kuma.localbind.ports.tcp}";
      };
    };
    caddy = {
      enable = true;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      configFile = pkgs.writeText "Caddyfile.Kuma" ''
        kuma.${infra.lan.domain} {
          bind ${infra.lan.services.kuma.ip}
          reverse_proxy ${infra.lan.services.kuma.localbind.ip}:${toString infra.lan.services.kuma.localbind.ports.tcp}
          tls acme@pki.lan {
                ca_root /etc/ca.crt
                ca https://pki.lan/acme/acme/directory
          }
          @not_intranet {
            not remote_ip ${infra.lan.network}
          }
          respond @not_intranet 403
          log {
            output file ${config.services.caddy.logDir}/access/proxy-read.log
          }
        }
        status.${infra.lan.domain} {
          bind ${infra.lan.services.status.ip}
          redir https://kuma.lan/status/info
          tls acme@pki.lan {
                ca_root /etc/ca.crt
                ca https://pki.lan/acme/acme/directory
          }
          @not_intranet {
            not remote_ip ${infra.lan.network}
          }
          respond @not_intranet 403
          log {
            output file ${config.services.caddy.logDir}/access/proxy-read.log
          }
        }
      '';
    };
  };
}
