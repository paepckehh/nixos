{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    pingvin-share = {
      enable = true;
      openFirewall = true; # 3000
    };
  };
}
