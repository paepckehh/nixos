{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./devops-go.nix
    ./devops-python.nix
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.shellAliases = {
    # "crush" = "CGO_ENABLED=0 go run github.com/charmbracelet/crush@latest";
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      crush
      # opencode
    ];
  };
}
