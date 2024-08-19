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
  security = {
    pam = {
      u2f = {
        enable = true;
        control = "sufficient"; # required
        cue = true;
        debug = true;
      };
      services = {
        login = {
          allowNullPassword = lib.mkForce false;
          failDelay = {
            enable = true;
            delay = 10000000;
          };
          logFailures = true;
          u2fAuth = true;
          unixAuth = true;
        };
        sudo = {
          allowNullPassword = lib.mkForce false;
          failDelay = {
            enable = true;
            delay = 10000000;
          };
          u2fAuth = true;
          unixAuth = true;
          logFailures = true;
          requireWheel = true;
        };
      };
    };
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
    shellAliases = {
      yubico-reload = "pkill ssh-agent ; ssh-add -k";
    };
  };
}
