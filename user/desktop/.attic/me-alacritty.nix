{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me.programs.alacritty = {
    enable = true;
    settings = {
      selection = {
        save_to_clipboard = true;
      };
      scrolling = {
        history = 100000;
      };
      font.size = 11;
      colors = {
        draw_bold_text_with_bright_colors = true;
        primary = {
          background = "#000000";
          foreground = "#fffbf6";
        };
        normal = {
          black = "#000000";
          red = "#eb4129";
          green = "#abe047";
          yellow = "#f6c744";
          blue = "#47a0f3";
          magenta = "#7b5cb0";
          cyan = "#64dbed";
          white = "#e5e9f0";
        };
        bright = {
          black = "#565656";
          red = "#ec5357";
          green = "#c0e17d";
          yellow = "#f9da6a";
          blue = "#49a4f8";
          magenta = "#a47de9";
          cyan = "#99faf2";
          white = "#ffffff";
        };
      };
      window = {
        decorations = "none";
        startup_mode = "Fullscreen";
      };
    };
  };
}
