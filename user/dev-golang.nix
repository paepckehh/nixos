{
  config,
  pkgs,
  lib,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      gnumake
      go-tools
      golangci-lint
    ];
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    nixvim = {
      # requires nixvim flake
      enable = true;
      colorschemes.catppuccin.enable = true;
      plugins.lualine.enable = true;
    };
  };
}
