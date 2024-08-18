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
    udev = {
      packages = [pkgs.yubikey-personalization];
      extraRules = ''
        ACTION=="remove",\
         ENV{ID_BUS}=="usb",\
         ENV{ID_MODEL_ID}=="0407",\
         ENV{ID_VENDOR_ID}=="1050",\
         ENV{ID_VENDOR}=="Yubico",\
         RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"'';
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs.gnupg.agent = {
    enable = lib.mkForce true;
    enableSSHSupport = lib.mkForce true;
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [pam_u2f];
  };
}
