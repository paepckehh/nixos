{lib, ...}: {
  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    plymouth = {
      enable = lib.mkForce true;
      logo = lib.mkForce "${../shared/bootimg/deb-adm.png}";
    };
  };
}
