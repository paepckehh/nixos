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
      murex
      nushell
      nushellPlugins.net
      nushellPlugins.query
      nushellPlugins.gstat
      nushellPlugins.formats
      nushellPlugins.highlights
      nufmt
    ];
  };
}
