{
  config,
  pkgs,
  lib,
  ...
}:
{
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
      asn
      bandwhich
      bmon
      dmidecode
      dnstracer
      dnsutils
      dust
      fastfetch
      fd
      gnumake
      gping
      gh
      inetutils
      jq
      keepassxc
      kmon
      moreutils
      ncdu
      netscanner
      nixfmt-rfc-style
      nix-init
      nix-output-monitor
      nixpkgs-review
      nix-prefetch-scripts
      nix-search-cli
      nix-top
      nix-tree
      nvme-cli
      onefetch
      openssl
      p7zip
      paper-age
      parted
      passage
      pciutils
      progress
      pv
      pwgen
      stress
      s-tui
      sysz
      tcping-go
      termshark
      tldr
      tlsinfo
      tree
      trippy
      tshark
      tz
      unzip
      usbutils
      ventoy-full
      xh
      yamlfmt
      yq
      yubikey-manager
    ];
  };
}
