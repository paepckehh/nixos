{
  config,
  pkgs,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    ollama = {
      enable = true;
      package = pkgs.unstable.ollama;
      host = "127.0.0.1";
      port = 11434;
      # openFirewall = false;
      # user = "ollama";
      # group = "ollama";
      # acceleration = false;
      # environmentVariables = [];
      # home = "";
      # models = "";
      # loadModels = [];
      # rocmOverrideGfx = "";
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      ollama-commit = "/home/me/.npm-packages/bin/ollama-commit --language en --api http://localhost:11434 --model mistral";
      tlm = "go run github.com/yusufcanb/tlm@latest $*";
      gollama = "go run github.com/sammcj/gollama@latest $*";
    };
  };
}
