# generic server base setup
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
  ##############
  #-=# USER #=-#
  ##############
  users = {
    users.restic = {
      group = "restic";
      isSystemUser = true;
    };
    groups.restic = {};
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.wrappers.restic = {
    source = lib.getExe pkgs.restic;
    owner = "restic";
    group = "restic";
    permissions = "500"; # or u=rx,g=,o=
    capabilities = "cap_dac_read_search+ep";
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    restic.backups.daily = {
      initialize = true;
      user = "restic";
      package = pkgs.writeShellScriptBin "restic" ''exec /run/wrappers/bin/restic "$@"'';
      # environmentFile = config.age.secrets."restic/env".path;
      # repositoryFile = config.age.secrets."restic/repo".path;
      # passwordFile = config.age.secrets."restic/password".path;
      paths = ["/var/lib"];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 6"
      ];
    };
  };
}
