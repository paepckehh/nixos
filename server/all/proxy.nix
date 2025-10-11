{
  pkgs,
  lib,
  config,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        proxy = {
          ip = "192.168.80.216";
          hostname = "proxy";
          ports.tcp = 3128;
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [
    {Address = "${infra.lan.services.proxy.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.proxy.ip} ${infra.lan.services.proxy.hostname} ${infra.lan.services.proxy.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.proxy.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    squid = {
      enable = true;
      proxyAddress = "${infra.lan.services.proxy.ip}";
      proxyPort = infra.lan.services.proxy.ports.tcp;
      validateConfig = true;
    };
  };

  ##################
  #-=# NIXPKGS #=-#
  ##################
  nixpkgs.config.permittedInsecurePackages = ["squid-7.0.1"];
}
