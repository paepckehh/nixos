# immich share media
# authelia/oauth app settings: https://docs.immich.app/administration/oauth/
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
  networking.extraHosts = "${infra.immich.ip} ${infra.immich.hostname} ${infra.immich.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.immich.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.immich.fqdn}" = {
      listenAddresses = [infra.immich.ip];
      extraConfig = ''import intraproxy ${toString infra.immich.localbind.port.http}'';
    };
    immich = {
      enable = true;
      host = infra.localhost.ip;
      port = infra.immich.localbind.port.http;
      settings = {
        server.externalDomain = infra.immich.url;
        passwordLogin.enabled = true;
        oauth = {
          enabled = true;
          autoLaunch = true;
          autoRegister = true;
          buttonText = "Anmeldung mit Authelia";
          clientId = infra.immich.app;
          clientSecret = "insecure_secret";
          issuerUrl = infra.sso.url;
          profileSigningAlgorithm = "none";
          roleClaim = "immich_role";
          scope = infra.sso.oidc.scope;
          signingAlgorithm = "RS256";
          storageLabelClaim = "preferred_username";
          storageQuotaClaim = "immich_quota";
          timeout = 30000;
          tokenEndpointAuthMethod = infra.sso.oidc.auth.post;
        };
      };
    };
  };
}
