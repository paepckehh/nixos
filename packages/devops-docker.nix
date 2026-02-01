{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [
    docker
    compose2nix
  ];

  virtualisation.docker.enable = true;
  users.users.me.extraGroups = ["docker"];
}
