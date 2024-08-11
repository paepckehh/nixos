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
        login.yubicoAuth = false;
        sudo.yubicoAuth = false;
      };
      yubico = {
        enable = false;
        challengeResponsePath = "$HOME/.yubico/challenge";
        control = "optional"; # required or optional
        debug = true;
        mode = "challenge-response";
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
      age-plugin-yubikey
      pcsclite
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
    enable = false;
    enableSSHSupport = false;
  };
}
