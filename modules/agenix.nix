{
  agenix,
  config,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./openssh-local-lockdown.nix
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = [pkgs.age agenix.packages.x86_64-linux.default];

  #############
  #-=# AGE #=-#
  #############
  # custom flake, need upstream input sops.nixosModules.sops
  # age = {
  #   age.keyFile = "/home/me/.config/sops/age/nix";
  #   secrets.openai_api_key = {
  #     path = "${config.sops.defaultSymlinkPath}/openai_api_key";
  #   };
  #   secrets.tibber_api_key = {
  #     path = "${config.sops.defaultSymlinkPath}/tibber_api_key";
  #   };
  #   secrets.ecoflow_api_key = {
  #     path = "${config.sops.defaultSymlinkPath}/ecoflow_api_key";
  #   };
  #   secrets.ecoflow_username = {
  #     path = "${config.sops.defaultSymlinkPath}/ecoflow_username";
  #   };
  #   secrets.ecoflow_password = {
  #     path = "${config.sops.defaultSymlinkPath}/ecoflow_password";
  #   };
  #   secrets.user_me_pwdhash = {
  #     path = "${config.sops.defaultSymlinkPath}/user_me_pwdhash";
  #   };
  # };
}
