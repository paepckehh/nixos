{
  config,
  pkgs,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [age sops];
  };
  ##############
  #-=# SOPS #=-#
  ##############
  # custom flake, need upstream input sops.nixosModules.sops
  sops = {
    age.keyFile = "/home/me/.config/sops/age/nix";
    defaultSopsFile = ./modules/resources/secrets.yaml;
    # defaultSymlinkPath = "/run/user/1000/secrets";
    # defaultSecretsMountPoint = "/run/user/1000/secrets.d";
    secrets.openai_api_key = {
      path = "${config.sops.defaultSymlinkPath}/openai_api_key";
    };
    secrets.tibber_api_key = {
      path = "${config.sops.defaultSymlinkPath}/tibber_api_key";
    };
    secrets.ecoflow_api_key = {
      path = "${config.sops.defaultSymlinkPath}/ecoflow_api_key";
    };
    secrets.ecoflow_username = {
      path = "${config.sops.defaultSymlinkPath}/ecoflow_username";
    };
    secrets.ecoflow_password = {
      path = "${config.sops.defaultSymlinkPath}/ecoflow_password";
    };
    secrets.user_me_pwdhash = {
      path = "${config.sops.defaultSymlinkPath}/user_me_pwdhash";
    };
  };
}
