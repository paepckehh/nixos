{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./devops-base.nix
    ./devops-db.nix
    ./devops-office.nix
    ./devops-ldap.nix
    ./devops-sec.nix
    ./devops-net.nix
  ];
}
