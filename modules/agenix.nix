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
      tibber = {
        file = ./resources/tibber.age;
        owner = "prometheus";
        group = "prometheus";
      };
      ecoflow-email = {
        file = ./resources/ecoflow-email.age;
        owner = "prometheus";
        group = "prometheus";
      };
      ecoflow-password = {
        file = ./resources/ecoflow-password.age;
        owner = "prometheus";
        group = "prometheus";
      };
      ecoflow-devices = {
        file = ./resources/ecoflow-devices.age;
        owner = "prometheus";
        group = "prometheus";
      };
      ecoflow-acccess-key = {
        file = ./resources/ecoflow-access-key.age;
        owner = "prometheus";
        group = "prometheus";
      };
      ecoflow-secret-key = {
        file = ./resources/ecoflow-secret-key.age;
        owner = "prometheus";
        group = "prometheus";
      };
    };
  };
}
