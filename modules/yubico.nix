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
        settings = {
          cue = true;
          debug = false;
        };
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
  programs = {
    ssh = {
      startAgent = lib.mkForce true;
      extraConfig = "AddKeysToAgent yes";
    };
    seahorse.enable = lib.mkForce false;
    gnupg.agent = {
      enable = lib.mkForce false;
      enableSSHSupport = lib.mkForce false;
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [pam_u2f];
  };
}
