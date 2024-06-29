{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./desktop.nix
  ];
  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    system-config-printer.enable = true;
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
      enable = lib.mkForce true;
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
