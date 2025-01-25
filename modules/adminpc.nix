{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [ ];

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    initrd.systemd.enable = lib.mkForce true;
    plymouth = {
      enable = lib.mkForce true;
      logo = lib.mkForce "${./resources/admpc.png}";
    };
  };

  ###########
  # console #
  ###########
  # How to get all installed kbd all options?
  # cd /nix/store && fd base.lst | xargs cat
  # see desktop/shared.nix for xserver setup
  console = {
    enable = lib.mkForce true;
    earlySetup = lib.mkForce true;
    keyMap = lib.mkForce "de";
    font = lib.mkForce "${pkgs.powerline-fonts}/share/consolefonts/ter-powerline-v18b.psf.gz";
    packages = with pkgs; [powerline-fonts];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    thinkfan = {
      enable = true;
    };
    tp-auto-kbbl.enable = true;
  };
}
