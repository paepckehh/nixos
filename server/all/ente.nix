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
  networking.extraHosts = "${infra.ente.ip} ${infra.ente.hostname} ${infra.ente.fqdn}";

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    ente = {
      api = {
        enable = true;
        domain = infra.ente.fqdn;
        enableLocalDB = true;
        nginx.enable = false;
        settings = {
          apps = {
            # accounts      = "accounts.${infra.ente.domain}";
            # cast          = "https://cast.${infra.ente.domain}";
            # public-albums = "https://photos.${infra.ente.domain}";
            # https://github.com/ente-io/ente/blob/main/server/configurations/local.yaml
            # key.encryption = "";
            # key.hash = "";
            # key.jwt.secret = "";
          };
        };
      };
      web = {
        enable = true;
        domains = {
          accounts = "accounts.${infra.ente.domain}";
          albums = "albums.${infra.ente.domain}";
          cast = "cast.${infra.ente.domain}";
          photos = "photos.${infra.ente.domain}";
        };
      };
    };
    caddy.virtualHosts."${infra.ente.fqdn}" = {
      listenAddresses = [infra.ente.ip];
      extraConfig = ''import intraproxy ${toString infra.ente.localbind.port.http}'';
    };
  };
}
