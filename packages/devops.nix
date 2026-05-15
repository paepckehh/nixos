{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./devops-db.nix
    ./devops-go.nix
    # ./devops-html.nix
    ./devops-net.nix
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
  services.sysprof.enable = false;

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      aria2
      certinfo-go
      binsider
      dmidecode
      file
      jq
      jqfmt
      gnumake
      hyperfine
      ncdu
      pciutils
      shellcheck
      shfmt
      s-tui
      sysz
      tlsinfo
      lazyjournal
      usbutils
      vale
      yamlfmt
    ];
  };
}
