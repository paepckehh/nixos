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
  networking.extraHosts = "${infra.miniflux.ip} ${infra.miniflux.hostname} ${infra.miniflux.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.miniflux.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.miniflux.fqdn}" = {
      listenAddresses = [infra.miniflux.ip];
      extraConfig = ''import intraproxy ${toString infra.miniflux.localbind.port.http}'';
    };
  };

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers.miniflux = {
    autoStart = true;
    privateNetwork = false;
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
      networking.hostName = infra.miniflux.hostname;

      #################
      #-=# SYSTEMD #=-#
      #################
      systemd.services.miniflux = {
        after = ["sockets.target"];
        wants = ["sockets.target"];
        wantedBy = ["multi-user.target"];
      };

      ##################
      #-=# SERVICES #=-#
      ##################
      services = {
        miniflux = {
          enable = true;
          config = {
            LISTEN_ADDR = "${infra.localhost.ip}:${toString infra.miniflux.localbind.port.http}";
            CREATE_ADMIN = false;
            DISABLE_LOCAL_AUTH = "1";
            OAUTH2_CLIENT_ID = "miniflux";
            OAUTH2_CLIENT_SECRET = "insecure_secret";
            OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://sso.home.corp";
            OAUTH2_OIDC_PROVIDER_NAME = "Authelia";
            OAUTH2_REDIRECT_URL = "https://miniflux.home.corp/oauth2/oidc/callback";
            OAUTH2_PROVIDER = "oidc";
            WEBAUTHN = "0";
            OAUTH2_USER_CREATION = "1";
            # HTTP_CLIENT_PROXIES = [];        # outbound proxies
            # METRICS_COLLECTOR = infra.one;   # prometheus
            # METRICS_REFRESH_INTERVAL = "60"; # refresh every 60 seconds
          };
        };
      };
    };
  };
}
