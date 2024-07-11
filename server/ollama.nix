{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    ollama = {
      enable = true;
      host = "127.0.0.1";
      port = "11434";
      openFirewall = false;
      sandbox = true;
      # environmentVariables = [];
      # home = "";
      # loadModels = [];
      # rocmOverrideGfx = "";
      # writeablePath = [];
    };
  };
}
