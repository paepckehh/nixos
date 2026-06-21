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
  environment.systemPackages = with pkgs; [jq];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.shellAliases = {
    "codescore" = "go run paepcke.de/codescore/cmd/codescore@latest";
    "crush" = "go run github.com/charmbracelet/crush@latest"; # upstream original
    "crushIT" = "/nix/persist/projects/_external/crush/crush"; # local modified derivate
    "codescoreIT" = "/nix/persist/projects/codescore/cmd/codescore/codescore"; # local modified derivate
  };
}
