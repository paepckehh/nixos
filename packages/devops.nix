{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./nfc.nix
    ./devops-go.nix
    ./devops-nixos.nix
    # ./tmux.nix
    # ./devops-db.nix
    # ./devops-html.nix
    # ./devops-net.nix
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
      gh
      hackernews-tui
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
      onefetch
      lazyjournal
      usbutils
      vale
      yamlfmt
    ];
  };
}
