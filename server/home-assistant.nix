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
        # defaults, needed for setup
          "esphome"
          "google_translate"
          "met"
          "radio_browser"
        # custom
          "heos"
          "sun"
          "apple_tv"
          "matter"
          "homekit"
          "homekit_controller"
          "bluetooth"
          "systemmonitor"
          "mobile_app"
          "network"
          "device_tracker"
          "ollama"
          "zha"
          "unifi"
        ];
    };
  };
}
