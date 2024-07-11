{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services.adguardhome = {
    enabled = true;
    mutableSettings = true;
    allowDHCP = false;
    openFirewall = false;
    settings.bind_port = 5353;
  };
}
