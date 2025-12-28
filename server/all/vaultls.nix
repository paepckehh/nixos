# WEBMTLS => VAULTLS: mtls certificate web gui
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
  networking.extraHosts = "${infra.webmtls.ip} ${infra.webmtls.hostname} ${infra.webmtls.fqdn}.";

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      "vaultls" = {
        file = ../../modules/resources/vaultls.age;
        owner = "vaultls";
        group = "vaultls";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups."vaultls" = {};
    users = {
      "vaultls" = {
        group = "vaultls";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh ssoentication
      };
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        vaultls = {
          autoStart = true;
          hostname = infra.webmtls.fqdn;
          image = "ghcr.io/7ritn/vaultls:latest";
          ports = ["${infra.localhost.ip}:${toString infra.webmtls.localbind.port.http}:80"];
          # volumes = ["/var/lib/vaultls:/app/data"]; # XXX map for prod
          environment = {
            VAULTLS_API_SECRET = "hsP9NjKLeoRsF72r3j0FPSNI3I6kO4TLqlkgphtX+J8="; # XXX rage it for prod
            VAULTLS_URL = infra.webmtls.url;
            # VAULTLS_OIDC_AUTH_URL = infra.sso.url.base;
            # VAULTLS_OIDC_CALLBACK_URL = infra.sso.url.callback;
            # VAULTLS_OIDC_ID = infra.webmtls.fqdn;
            # VAULTLS_OIDC_SECRET = infra.webmtls.oidc.secrect;
          };
        };
      };
    };
  };

  #################
  #-=# SERVICE #=-#
  #################
  services = {
    caddy.virtualHosts."${infra.webmtls.fqdn}" = {
      listenAddresses = [infra.webmtls.ip];
      extraConfig = ''import adminproxy ${toString infra.webmtls.localbind.port.http}'';
    };
  };
}
