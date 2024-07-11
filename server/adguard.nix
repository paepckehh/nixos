{
  config,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    resolved.enable = false;
    adguardhome = {
      enable = true;
      mutableSettings = true;
      openFirewall = false;
      settings = {
        http = {
          address = "127.0.0.1:3000";
        };
        dns = {
          bind_hosts = ["127.0.0.1"];
          bind_port = 53;
        };
      };
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    nameservers = lib.mkForce ["127.0.0.1"];
  };
}
