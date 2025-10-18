{
  config,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    send = {
      enable = true;
      port = 1443;
      openFirewall = false;
    };
  };
}
