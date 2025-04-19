{pkgs, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    music-assistant = {
      enable = true;
      package = pkgs.unstable.music-assistant;
    };
    home-assistant = {
      enable = true;
      package = pkgs.unstable.home-assistant;
      config = {
        default_config = {};
      };
      extraComponents = [
        # defaults (needed for init/setup)
        "esphome"
        "google_translate"
        "met"
        "radio_browser"
        # custom
        "apple_tv"
        "bluetooth"
        "device_tracker"
        "heos"
        "homekit"
        "homekit_controller"
        "matter"
        "music_assistant"
        "mobile_app"
        "mqtt"
        "network"
        "roomba"
        "sun"
        "systemmonitor"
        "tibber"
        "ollama"
        "unifi"
        "zha"
      ];
    };
  };
}
