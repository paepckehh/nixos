{
  config,
  lib,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        paste = {
          ip = "192.168.80.207";
          hostname = "paste";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7007;
          };
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.paste.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.paste.ip} ${infra.lan.services.paste.hostname} ${infra.lan.services.paste.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.paste.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy = {
      enable = true;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      virtualHosts."paste.${infra.lan.domain}".extraConfig = ''
        bind ${infra.lan.services.paste.ip}
        reverse_proxy ${infra.lan.services.paste.localbind.ip}:${toString infra.lan.services.paste.localbind.ports.tcp}
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
        }'';
    };
    wastebin = {
      enable = true;
      settings = {
        WASTEBIN_TITLE = "${infra.lan.services.paste.hostname}.${infra.lan.domain}";
        WASTEBIN_MAX_BODY_SIZE = 10485760;
        WASTEBIN_HTTP_TIMEOUT = 10;
        WASTEBIN_BASEURL = "https://${infra.lan.services.paste.hostname}.${infra.lan.domain}";
        WASTEBIN_ADDRESS_PORT = "${infra.lan.services.paste.localbind.ip}:${toString infra.lan.services.paste.localbind.ports.tcp}";
        WASTEBIN_THEME = "monokai";
      };
    };
  };
}
