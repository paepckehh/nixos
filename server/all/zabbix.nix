{
  config,
  pkgs,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    zabbixServer = {
      enable = true;
      openFirewall = true;
      listen = {
        ip = "0.0.0.0";
        port = "10051";
      };
    };
    zabbixWeb = {
      enable = true;
      hostname = "zabbix.lan";
      server = {
        address = "127.0.0.1";
        port = "10051";
      };
      httpd.virtualHost.local = {
        ip = "127.0.0.1";
        port = "80";
        ssl = false;
      };
    };
  };
}
