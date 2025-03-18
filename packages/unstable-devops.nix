{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./neovim.nix
    ./unstable-netops.nix
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs.unstable; [
      aria2
      curlie
      gh
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
      nufmt
      nix-init
      nixfmt-rfc-style
      nixpkgs-review
      nix-prefetch-scripts
      nix-search-cli
      ventoy-full
    ];
  };
}
