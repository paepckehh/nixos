{
  pkgs,
  lib,
  ...
}: {
  ################
  # HOME-MANAGER #
  ################
  home-manager.users.me.programs = {
    thunderbird = {
      enable = true;
      package = pkgs.thunderbird;
      profiles = {};
    };
  };
}
