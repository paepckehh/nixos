{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    ollama = {
      enable = true;
      host = "0.0.0.0";
      port = 6060;
      openFirewall = false;
      user = "ollama";
      group = "ollama";
      # acceleration = false;
      # environmentVariables = [];
      # home = "";
      # models = "";
      # loadModels = [];
      # rocmOverrideGfx = "";
    };
  };
}
