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
    cage = {
      enable = true;
      user = "kiosk";
      program = "${pkgs.librefox}/bin/librefox -kiosk -private-window http://www.heise.de";
    };
    autosuspend.enable = lib.mkForce false;
    printing.enable = lib.mkForce false;
    pipewire = {
      enable = lib.mkForce false;
      pulse.enable = lib.mkForce false;
      wireplumber.enable = lib.mkForce false;
      alsa.enable = lib.mkForce false;
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.kiosk = {
    home = {
      stateVersion = config.system.nixos.release;
      enableNixpkgsReleaseCheck = false;
      # homeDirectory = "/home/kiosk";
      keyboard.layout = "us,de";
    };
    programs = {
      librewolf = {
        enable = true;
        policies = {
          SanitizeOnShutdown = {
            Cache = true;
            Cookies = true;
            Downloads = true;
            FormData = true;
            History = true;
            Sessions = true;
            SiteSettings = true;
            OfflineApps = true;
          };
        };
        settings = {
          "browser.cache.disk.enable" = false;
          "browser.compactmode.show" = true;
          "browser.startup.homepage" = "";
          "signon.rememberSignons" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.firstparty.isolate" = true;
          "privacy.resistFingerprinting" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "network.trr.mode" = 0;
          "webgl.disabled" = false;
        };
      };
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.rtkit.enable = lib.mkForce false;

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      me = {
        initialHashedPassword = "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7"; # start
        description = "kiosk";
        uid = 65501;
        group = "nogroup";
        createHome = true;
        isNormalUser = true;
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
  };
}
