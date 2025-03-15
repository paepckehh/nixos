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
    home-assistant = {
      enable = true;
      package = pkgs.unstable.home-assistant;
      config = {
        homeassistant = {
          name = "Home";
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          elevation = "!secret elevation";
          unit_system = "metric";
          time_zone = "UTC";
        };
        frontend = {
          themes = "!include_dir_merge_named themes";
        };
        http = {};
        feedreader.urls = ["https://nixos.org/blogs.xml"];
      };
    };
  };
}
