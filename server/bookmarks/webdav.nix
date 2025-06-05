{
  config,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    webdav-server-rs = {
      enable = true;
      settings = {
        server.listen = ["192.168.80.202:8443"];
        accounts = {
          auth-type = "pam";
          acct-type = "unix";
          realm = "Webdav Server";
        };
        pam = {
          service = "other";
          cache-timeout = 120;
          threads = 4;
        };
        location = [
          {
            route = ["/home/:user/*path"];
            directory = "~";
            handler = "filesystem";
            methods = ["webdav-rw"];
            autoindex = true;
            auth = "true";
            setuid = true;
          }
        ];
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."10-lan".addresses = [{Address = "192.168.80.202/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "192.168.80.202 bookmark bookmark.${config.networking.domain}";
    firewall.allowedTCPPorts = [8443];
  };
}
