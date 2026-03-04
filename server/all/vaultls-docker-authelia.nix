# WEBMTLS => VAULTLS: mtls certificate web gui
# sudo mkdir -p /var/lib/vaultls/data && sudo chown -R 1000:1000 /var/lib/vaultls
# sudo docker ps
# sudo docker cp rootCA.crt <containerid>:/tmp
# sudo docker exec -it <containerid> sh
#  cd /tmp && ls -la
#  cp /tmp/rootCA.crt /usr/local/share/ca-certificates/root_cert.crt
#  update-ca-certificates
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
  networking.extraHosts = "${infra.vaultls.ip} ${infra.vaultls.hostname} ${infra.vaultls.fqdn}.";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.vaultls.namespace}".addresses = [{Address = "${infra.vaultls.ip}/32";}];

  #################
  #-=# SERVICE #=-#
  #################
  services = {
    caddy.virtualHosts."${infra.vaultls.fqdn}" = {
      listenAddresses = [infra.vaultls.ip];
      extraConfig = ''import intraproxy ${toString infra.vaultls.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        vaultls = {
          autoStart = true;
          hostname = infra.vaultls.name;
          image = "ghcr.io/7ritn/vaultls:latest";
          ports = ["${infra.localhost.ip}:${toString infra.vaultls.localbind.port.http}:80"];
          volumes = ["/var/lib/vaultls/data:/app/data"];
          environment = {
            VAULTLS_API_SECRET = infra.vaultls.api;
            VAULTLS_DB_SECRET = infra.vaultls.db;
            VAULTLS_LOG_LEVEL = infra.log.trace;
            VAULTLS_URL = infra.vaultls.url;
            VAULTLS_OIDC_AUTH_URL = infra.sso.url;
            VAULTLS_OIDC_CALLBACK_URL = infra.vaultls.oidc.callback.url;
            VAULTLS_OIDC_ID = infra.vaultls.fqdn;
            VAULTLS_OIDC_SECRET = infra.vaultls.oidc.secret;
            VAULTLS_MAIL_HOST = infra.smtp.admin.ip;
            VAULTLS_MAIL_PORT = "${toString infra.port.smtp}";
            VAULTLS_MAIL_FROM = infra.admin.email;
          };
        };
      };
    };
  };
}
