{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      libnfc-nci
      libnfc
      neard
      pcsc-tools
    ];
  };
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    pcscd = {
      enable = true;
      plugins = with pkgs; [ccid acsccid libacr38u scmccid ifdnfc pcsc-cyberjack pcsc-scm-scl011];
    };
  };
}
