{pkgs, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
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
        "mobile_app"
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
