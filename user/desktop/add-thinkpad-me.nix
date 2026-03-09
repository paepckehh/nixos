{
  config,
  pkgs,
  lib,
  ...
}: {
  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    home = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_USE_XINPUT2 = "1";
      };
      packages = with pkgs; [
        gnomeExtensions.thinkpad-battery-threshold
      ];
    };
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            thinkpad-battery-threshold.extensionUuid
          ];
        };
      };
    };
  };
}
