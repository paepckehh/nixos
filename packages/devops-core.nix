{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./base.nix
    ./devops-base.nix
    ./devops-go.nix
    ./devops-sec.nix
    ./devops-net.nix
    ./devops-nixos.nix
  ];
}
