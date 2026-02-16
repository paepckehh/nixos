{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ./config.nix).infra;
in {
  #############
  #-=# AGE #=-#
  #############
  # username=<USERNAME>
  # domain=<DOMAIN>
  # password=<PASSWORD>
  age.secrets.smb1.file = ../modules/resources/smb1.age;

  fileSystems = {
    "/nix/persist/mnt/it/Public" = {
      device = "//10.20.6.102/Public";
      fsType = "cifs";
      options = ["x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,credentials=${config.age.secrets.smb1.path},uid=it,gid=it" "nofail"];
    };
  };
}
