{
  config,
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    udev.packages = [pkgs.yubikey-personalization];
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs.gnupg.agent = {
    enable = lib.mkForce true;
    enableSSHSupport = lib.mkForce true;
  };
}
