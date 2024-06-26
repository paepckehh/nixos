{
  config,
  pkgs,
  lib,
  ...
}: {
  boot = {
    initrd = {
      luks = {
        fido2Support = false;
        gpgSupport = false;
        mitigateDMAAttacks = true;
        yubikeySupport = false;
      };
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################

  security = {
    pam = {
      services = {
        login.u2fAuth = false;
        sudo.u2fAuth = true;
      };
      yubico = {
        enable = false;
        debug = true;
        control = "required";
        mode = "challenge-response";
        id = "012345";
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################

  # pam_u2f
  # libu2f-host
  # yubico-pam

  environment = {
    systemPackages = with pkgs; [
      yubioath-flutter
      yubikey-touch-detector
      yubikey-manager
      yubikey-manager-qt
      yubikey-personalization
      yubikey-personalization-gui
    ];
  };

  ##################
  #-=# SERVICES #=-#
  ##################

  services = {
    pcscd.enable = true;
    udev.extraRules = ''
      ACTION=="remove",\
      ENV{ID_BUS}=="usb",\
      ENV{ID_MODEL_ID}=="0407",\
      ENV{ID_VENDOR_ID}=="1050",\
      ENV{ID_VENDOR}=="Yubico",\
      RUN+="${pkgs.systemd}/bin/loginctl lock-sessions" '';
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
