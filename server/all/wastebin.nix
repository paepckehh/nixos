{
  config,
  lib,
  ...
}: let
  infra = {
    lan = {
      domain = "corp";
      namespace = "00-${infra.lan.domain}";
      services = {
        pki = {
          ip = "10.20.0.20";
          hostname = "pki";
          ports.tcp = 443;
          domain = "adm.${infra.lan.domain}";
          network = "10.20.0.0/24";
        };
        paste = {
          ip = "10.20.0.21";
          hostname = "paste";
          domain = "adm.${infra.lan.domain}";
          network = "10.20.0.0/24";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7021;
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
    extraHosts = "${infra.lan.services.paste.ip} ${infra.lan.services.paste.hostname} ${infra.lan.services.paste.hostname}.${infra.lan.services.paste.domain}";
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
      virtualHosts."${infra.lan.services.paste.hostname}.${infra.lan.services.paste.domain}".extraConfig = ''
        bind ${infra.lan.services.paste.ip}
        reverse_proxy ${infra.lan.services.paste.localbind.ip}:${toString infra.lan.services.paste.localbind.ports.tcp}
        tls acme@${infra.lan.services.pki.hostname}.${infra.lan.services.pki.domain} {
              ca_root /etc/ca.crt
              ca https://${infra.lan.services.pki.hostname}.${infra.lan.services.pki.domain}/acme/acme/directory
        }
        @not_intranet {
          not remote_ip ${infra.lan.services.paste.network}
        }
        respond @not_intranet 403
      '';
    };
    wastebin = {
      enable = true;
      settings = {
        WASTEBIN_TITLE = "${infra.lan.services.paste.hostname}.${infra.lan.services.paste.domain}";
        WASTEBIN_MAX_BODY_SIZE = 10485760;
        WASTEBIN_HTTP_TIMEOUT = 10;
        WASTEBIN_BASEURL = "https://${infra.lan.services.paste.hostname}.${infra.lan.services.paste.domain}";
        WASTEBIN_ADDRESS_PORT = "${infra.lan.services.paste.localbind.ip}:${toString infra.lan.services.paste.localbind.ports.tcp}";
        WASTEBIN_THEME = "monokai";
      };
    };
  };
}
