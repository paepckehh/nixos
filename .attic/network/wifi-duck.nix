{
  config,
  lib,
  ...
}: {
  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    duck = {
      file = ../modules/resources/duckk.age;
      owner = "root";
      group = "wheel";
    };
  };
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    networkmanager.enable = lib.mkForce false;
    wireless = {
      enable = lib.mkForce true;
      networks."Duck" = {
        auth = ''
          key_mgmt SAE
          sae_password ext:sae_duck
          ieee80211w 2
        '';
        secretsFile = config.age.secrets.duck.path;
      };
    };
  };
}
