{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [];

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    iotop.enable = true;
    usbtop.enable = true;
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs.unstable; [
      amdgpu_top
      aria2
      certinfo-go
      curlie
      dmidecode
      gh
      gnumake
      golangci-lint
      go-tools
      httpie
      hyperfine
      murex
      ncdu
      nixfmt-rfc-style
      nix-init
      nixpkgs-review
      nix-prefetch-scripts
      nix-search-cli
      nufmt
      nushell
      nushellPlugins.formats
      nushellPlugins.gstat
      nushellPlugins.net
      nushellPlugins.query
      pciutils
      shellcheck
      shfmt
      s-tui
      sysz
      tlsinfo
      lazygit
      lazyjournal
      usbutils
      vale
      ventoy-full
      yamlfmt
    ];
  };
}
