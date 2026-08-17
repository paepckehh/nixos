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
  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      mp = {
        initialHashedPassword = "$y$j9T$kfoRrF1T9PX-FAIL";
        description = "mp";
        group = "users";
        createHome = true;
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = ["users" "wheel" "backup" "networkmanager" "audio" "input" "video"];
        openssh.authorizedKeys.keys = lib.mkDefault ["ssh-ed25519 AAA-#locked#-"];
      };
    };
  };
}
