{
  lib,
  config,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        paperless = {
          ip = "192.168.80.216";
          hostname = "paperless";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7016;
          };
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [
    {Address = "${infra.lan.services.paperless.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.paperless.ip} ${infra.lan.services.paperless.hostname} ${infra.lan.services.paperless.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.paperless.ports.tcp];
  };

  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    paperless = {
      file = ../../modules/resources/pki-pwd.age;
      owner = "paperless";
      group = "paperless";
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    paperless = {
      enable = true;
      passwordFile = config.age.secrets.paperless.path;
      address = "${infra.lan.services.paperless.localbind.ip}";
      port = infra.lan.services.paperless.localbind.ports.tcp;
      settings = {
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [".DS_STORE/*" "desktop.ini"];
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
      };
    };
    caddy = {
      enable = true;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      virtualHosts."paperless.${infra.lan.domain}".extraConfig = ''
        bind ${infra.lan.services.paperless.ip}
        reverse_proxy ${infra.lan.services.paperless.localbind.ip}:${toString infra.lan.services.paperless.localbind.ports.tcp}
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
  };
}
