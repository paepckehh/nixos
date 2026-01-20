# immich share media
# authelia/oauth app settings: https://docs.immich.app/administration/oauth/
# status: container broken
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
      extraConfig = ''import intracontainer ${toString infra.immich.container.ip}'';
      # extraConfig = ''import intraproxy ${toString infra.immich.localbind.port.http}'';
    };
  };

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers.immich = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = infra.container.interface;
    localAddress = "${infra.immich.container.ip}/24";
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      #################
      #-=# IMPORTS #=-#
      #################
      imports = [../../client/env.nix];

      ####################
      #-=# NETWORKING #=-#
      ####################
      networking = {
        enableIPv6 = false;
        hostName = infra.immich.hostname;
      };

      ################
      #-=# SYSTEM #=-#
      ################
      system.stateVersion = "26.05";

      ##################
      #-=# SERVICES #=-#
      ##################
      services = {
        immich = {
          enable = true;
          # host = infra.immich.container.ip;
          host = infra.localhost.ip;
          port = infra.port.http;
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
              profileSigningAlgorithm = infra.none;
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
    };
  };
}
