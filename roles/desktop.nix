{
  config,
  pkgs,
  ...
}: {

  ##################
  #-=# PROGRAMS #=-#
  ##################

  programs = {
    system-config-printer.enable = true;
    nm-applet.enable = true;
    sniffnet.enable = true;
    tuxclocker.enable = true;
    virt-manager.enable = true;
    coolercontrol.enable = true;
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################

  environment = {
    systemPackages = with pkgs; [
      kitty
      librewolf
    ];
  };


  ##################
  #-=# SERVICES #=-#
  ##################

  services = {
    avahi.enable = false;
    gnome.evolution-data-server.enable = lib.mkForce false;
    printing.enable = true;
    xserver = {
      enable = true;
      xkb = {
        layout = "gb";
        variant = "";
      };
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
}
