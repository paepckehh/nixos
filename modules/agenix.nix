{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./openssh-local-lockdown.nix
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [ragenix rage]; # rustify age

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      tibber.file = ./resources/tibber.age;
    };
  };
}
