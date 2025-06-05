{config, ...}: {
  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    duck = {
      file = ../modules/resources/duck.age;
      owner = "root";
      group = "wheel";
    };
  };
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    wireless = {
      networks."Duck" = {
        auth = ''
          key_mgmt SAE
          sae_password ext:sae_duck
          ieee80211w 2
        '';
        secretsFile = config.age.secrets.duck.path;
      };
      userControlled = {
        enable = true;
        group = "users";
      };
    };
  };
}
