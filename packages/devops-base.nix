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
    sessionVariables = {
      NIX_PACKAGE_SEARCH_EXPERIMENTAL = "true";
    };
    systemPackages = with pkgs; [
      aria2
      certinfo-go
      cryptsetup
      binsider
      dmidecode
      file
      jqfmt
      gh
      gnumake
      httpie
      hyperfine
      ncdu
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
      yamlfmt
    ];
  };
}
