{pkgs, ...}: {
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
