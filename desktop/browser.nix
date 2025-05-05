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
      program = lib.mkDefault "${pkgs.librewolf}/bin/librewolf";
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

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      kiosk = {
        initialHashedPassword = "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7"; # start
        description = "kiosk";
        uid = 65501;
        createHome = true;
        isNormalUser = true;
        group = "kiosk";
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
    groups.kiosk = {};
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.rtkit.enable = lib.mkForce false;
}
