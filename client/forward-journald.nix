{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../siteconfig/config.nix).infra;
in {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    journald = {
      storage = lib.mkForce "volatile";
      upload = {
        enable = lib.mkForce true;
        settings.Upload.URL = lib.mkForce infra.syslog.url;
      };
    };
  };
}
