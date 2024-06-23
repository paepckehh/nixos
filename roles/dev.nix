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
      cmake
      hugo
      go
      gh
      shfmt
      shellcheck
      vimPlugins.vim-shellcheck
      vimPlugins.vim-go
      vimPlugins.vim-git
    ];
  };
  variables = {
    SHELLCHECK_OPTS = "-e SC2086";
  };
}
