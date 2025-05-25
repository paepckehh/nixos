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
    sessionVariables = {
      NIX_PACKAGE_SEARCH_EXPERIMENTAL = "true";
    };
    systemPackages = with pkgs; [
      amdgpu_top
      aria2
      certinfo-go
      curlie
      cryptsetup
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
      nps
      marmite
      parted
      pciutils
      powertop
      shellcheck
      shfmt
      s-tui
      sysz
      tlsinfo
      lazygit
      lazyjournal
      usbutils
      vale
      yamlfmt
      # nvme-rs
      # ventoy-full
    ];
  };
}
