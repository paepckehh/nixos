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
      aria2
      curlie
      gnumake
      go-tools
      golangci-lint
      httpie
      hyperfine
      shellcheck
      shfmt
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
