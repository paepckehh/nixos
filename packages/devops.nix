{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./base.nix
    ./devops-go.nix
    ./devops-nixos.nix
  ];

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
  # services.sysprof.enable = false;

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      aria2
      certinfo-go
      binsider
      dmidecode
      fido2-manage
      file
      gh
      jq
      jqfmt
      gnumake
      hyperfine
      pciutils
      pcsc-tools
      shellcheck
      shfmt
      s-tui
      sysz
      tlsinfo
      onefetch
      lazyjournal
      libfido2
      usbutils
      vale
      yamlfmt
    ];
  };
}
