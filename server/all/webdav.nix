{
  lib,
  pkgs,
  config,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        webdav = {
          ip = "192.168.80.203";
          hostname = "webdav";
          ports.tcp = 8443;
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.webdav.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.webdav.ip} ${infra.lan.services.webdav.hostname} ${infra.lan.services.webdav.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.webdav.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    webdav-server-rs = {
      enable = true;
      settings = {
        server.listen = ["${infra.lan.services.webdav.ip}:${toString infra.lan.services.webdav.ports.tcp}"];
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
}
