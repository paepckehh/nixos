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
        owncloud = {
          ip = "10.20.0.120";
          hostname = "cloud";
          domain = "adm.${infra.lan.domain}";
          network = "10.20.0.0/24";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7120;
          };
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.owncloud.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.owncloud.ip} ${infra.lan.services.owncloud.hostname} ${infra.lan.services.owncloud.hostname}.${infra.lan.services.owncloud.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.owncloud.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy = {
      enable = false;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      virtualHosts."${infra.lan.services.owncloud.hostname}.${infra.lan.services.owncloud.domain}".extraConfig = ''
        bind ${infra.lan.services.owncloud.ip}
        reverse_proxy ${infra.lan.services.owncloud.localbind.ip}:${toString infra.lan.services.owncloud.owncloud.ports.tcp}
        tls acme@${infra.lan.services.pki.hostname}.${infra.lan.services.pki.domain} {
              ca_root /etc/ca.crt
              ca https://${infra.lan.services.pki.hostname}.${infra.lan.services.pki.domain}/acme/acme/directory
        }
        @not_intranet {
          not remote_ip ${infra.lan.services.owncloud.network}
        }
        respond @not_intranet 403
      '';
    };
    ocis = {
      enable = true;
      address = "${infra.lan.services.owncloud.localbind.ip}";
      port = infra.lan.services.owncloud.localbind.ports.tcp;
      url = "http://${infra.lan.services.owncloud.localbind.ip}:${toString infra.lan.services.owncloud.localbind.ports.tcp}";
      environment = {
        CS3_ALLOW_INSECURE = "true";
        STORAGE_USERS_MOUNT_ID = "982";
        GATEWAY_STORAGE_USERS_MOUNT_ID = "123";
        GRAPH_APPLICATION_ID = "1234";
        IDM_IDPSVC_PASSWORD = "super-secret-idp-account-pug-token";
        IDM_REVASVC_PASSWORD = "super-secret-resvc-account-pug-token";
        IDM_SVC_PASSWORD = "super-secret-svc-account-ass-token";
        IDP_ISS = "https://localhost:9200";
        IDP_TLS = "false";
        OCIS_LDAP_BIND_PASSWORD = "super-secret-ladp-dove-token";
        OCIS_LOG_LEVEL = "error";
        OCIS_MOUNT_ID = "982";
        OCIS_SERVICE_ACCOUNT_ID = "982";
        OCIS_SERVICE_ACCOUNT_SECRET = "super-secret-service-account-wolf-token";
        OCIS_SYSTEM_USER_API_KEY = "super-secret-service-api-lion-token";
        OCIS_STORAGE_USERS_MOUNT_ID = "982";
        OCIS_SYSTEM_USER_ID = "982";
        OCIS_SMTP_SENDER = "me@localhost";
        OCIS_INSECURE = "true";
        OCIS_INSECURE_BACKENDS = "true";
        OCIS_JWT_SECRET = "super-secret-jwt-cat-token";
        OCIS_TRANSFER_SECRET = "super-secret-transfer-dog-token";
        OCIS_MACHINE_AUTH_API_KEY = "super-secret-maschine-squirrel-token";
        TLS_INSECURE = "true";
        TLS_SKIP_VERIFY_CLIENT_CERT = "true";
        WEBDAV_ALLOW_INSECURE = "true";
      };
    };
  };
}
