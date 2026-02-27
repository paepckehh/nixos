# WEBMTLS => VAULTLS: mtls certificate web gui
# sudo mkdir -p /var/lib/vaultls/data && sudo chown -R 1000:1000 /var/lib/vaultls
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
          # extraOptions = ["--network=host"];
          image = "ghcr.io/7ritn/vaultls:latest";
          ports = ["${infra.localhost.ip}:${toString infra.vaultls.localbind.port.http}:80"];
          volumes = ["/var/lib/vaultls/data:/app/data"];
          environment = {
            VAULTLS_API_SECRET = infra.vaultls.api;
            VAULTLS_DB_SECRET = infra.vaultls.db;
            VAULTLS_LOG_LEVEL = "debug";
            VAULTLS_URL = infra.vaultls.url;
            VAULTLS_OIDC_AUTH_URL = infra.sso.url;
            VAULTLS_OIDC_CALLBACK_URL = infra.vaultls.oidc.callback.url;
            VAULTLS_OIDC_ID = infra.vaultls.fqdn;
            VAULTLS_OIDC_SECRET = infra.vaultls.oidc.secret;
          };
        };
      };
    };
  };
}
