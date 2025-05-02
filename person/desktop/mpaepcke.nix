{
  config,
  lib,
  home-manager,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../mpaepcke.nix
    ../../user/desktop/me.nix
  ];
}
######################
#-=# HOME-MANAGER #=-#
######################
# home-manager.users.me.home.programs.librewolf.profiles.default.bookmarks = lib.importJSON ./resources/bookmarks-personal.json;

