{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services.adguardhome = {
    enable = true;
    allowDHCP = false;
    host = "127.0.0.1";
    port = "3000";
    mutableSettings = true;
    openFirewall = false;
    settings = {
      http = {
        address = "127.0.0.1:3000";
      };
      dns = {
        bind_hosts = ["127.0.0.1"];
        bind_port = 5353;
      };
    };
  };
}
