{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    ollama = {
      enable = true;
      host = "127.0.0.1";
      port = 11434;
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
