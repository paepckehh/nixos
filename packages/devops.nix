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

  ##################
  #-=# SERVICES #=-#
  ##################
  services.sysprof.enable = true;

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    sessionVariables = {
      NIX_PACKAGE_SEARCH_EXPERIMENTAL = "true";
    };
    systemPackages = with pkgs; [
      aria2
      certinfo-go
      curlie
      cryptsetup
      delta
      dmidecode
      file
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
      # amdgpu_top
      # nvme-rs
      # ventoy-full
    ];
  };
}
