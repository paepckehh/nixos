{pkgs, ...}: {
  #################
  #-=# NIXPKGS #=-#
  #################
  nixpkgs.config.allowUnfree = true;

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      "dss" = "sh /etc/dss-start.sh";
    };
    systemPackages = with pkgs; [adoptopenjdk-icedtea-web jdk8];
    etc."dss-start.sh".text = "javaws /etc/dss-portal.jnlp";
    etc."dss.png".source = resources/dss.png;
    etc."dss.desktop".source = resources/dss.desktop;
    etc."dss-portal.jnlp".source = resources/dss-portal.jnlp;
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs.java = {
    enable = true;
    binfmt = true;
    package = pkgs.jdk8;
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    home.file.".local/share/applications/dss.desktop".source = resources/dss.desktop;
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell".favorite-apps = ["dss.desktop"];
        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/customDSS/"];
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/customDSS" = {
          name = "dss online portal";
          command = "javaws /etc/dss-portal.jnlp";
          binding = "<Super>D";
        };
      };
    };
  };
}
