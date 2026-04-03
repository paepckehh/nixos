{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./base.nix
    ./devops-base.nix
    ./devops-go.nix
    ./devops-html.nix
    ./devops-net.nix
    ./devops-nixos.nix
  ];
}
