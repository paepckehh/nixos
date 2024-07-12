{
  config,
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    system-config-printer.enable = lib.mkForce true;
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      betterbird
      libreoffice-qt6-fresh
    ];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    printing = {
      enable = lib.mkDefault true;
      stateless = true;
      clientConf = ''
        # ServerName cups.intra
      '';
      startWhenNeeded = true;
      cups-pdf = {
        enable = true;
      };
    };
  };
}
