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
  environment.systemPackages = with pkgs; [herdr];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.shellAliases = {
    "codescore" = "go run paepcke.de/codescore/cmd/codescore@latest";
    "codescore.local" = "/nix/persist/projects/codescore/cmd/codescore/codescore"; # local sonic extended derivate
    "crush.local" = "/nix/persist/projects/_external/crush/crush"; # local sonic derivate
    "crush.release" = "go run github.com/charmbracelet/crush@latest"; # upstream release
    "crush.main" = "go run github.com/charmbracelet/crush@main"; # upstream main-last-commit
    "trainer" = "go run github.com/makesometh-ing/trainer/cmd/trainer@latest";
  };
}
