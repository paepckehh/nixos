{pkgs, ...}: {
  # nixpkgs.config.allowUnfreePredicate = pkg:
  #  builtins.elem (lib.getName pkg) ["corefonts"];
  #
  # fonts.fonts = with pkgs; [corefonts];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [
    vlc
    uxplay
  ];
}
