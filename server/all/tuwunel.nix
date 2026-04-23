# matrix messenger
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
  networking.extraHosts = "${infra.matrix.ip} ${infra.matrix.hostname} ${infra.matrix.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.matrix.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy = {
      virtualHosts."${infra.matrix.externalHostname}" = {
        listenAddresses = [infra.matrix.ip];
        extraConfig = ''import intraproxy ${toString infra.matrix.localbind.port.http}'';
      };
    };
    matrix-tuwunel = {
      enable = true;
      settings = {
        global = {
          address = [infra.localhost.ip];
          port = [infra.matrix.localbind.port.http];
          server_name = infra.matrix.externalHostname;
          allow_encryption = true;
          allow_federation = false;
          allow_registration = infra.matrix.self-register.enable;
          registration_token = infra.matrix.self-register.password;
          rocksdb_compression_algo = "zstd";
          new_user_displayname_suffix = "";
          identity_provider = [
            {
              brand = infra.sso.app2;
              name = infra.sso.app2;
              client_id = infra.matrix.name;
              client_secret = infra.sso.oidc.secret;
              callback_url = "${infra.matrix.url}/_matrix/client/unstable/login/sso/callback/${infra.matrix.name}";
              issuer_url = infra.sso.url;
              default = true;
              discovery = true;
              trusted = true;
              unique_id_fallbacks = false;
              registration = true;
              userid_claims = ["openid"]; # XXX
            }
          ];
        };
      };
    };
  };
}
