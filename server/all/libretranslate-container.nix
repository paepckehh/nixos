# libretranslate
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.translate.ip} ${infra.translate.hostname} ${infra.translate.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.translate.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.translate.fqdn}" = {
      listenAddresses = [infra.translate.ip];
      extraConfig = ''import intracontainer ${infra.translate.container.ip} ${toString infra.translate.localbind.port.http}'';
    };
  };

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers.libretranslate = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = infra.container.interface;
    localAddress = "${infra.translate.container.ip}/${toString infra.container.netmask}";
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      #################
      #-=# IMPORTS #=-#
      #################
      imports = [../../client/env.nix];

      ####################
      #-=# NETWORKING #=-#
      ####################
      networking = {
        enableIPv6 = false;
        hostName = infra.translate.hostname;
      };

      ################
      #-=# SYSTEM #=-#
      ################
      system.stateVersion = "26.05";

      ##################
      #-=# SERVICES #=-#
      ##################
      services = {
        nginx.virtualHosts."${infra.translate.fqdn}" = {
          forceSSL = false;
          enableACME = false;
          listen = [
            {
              addr = infra.translate.container.ip;
              port = infra.port.http;
            }
          ];
        };
        libretranslate = {
          enable = true;
          host = infra.localhost.ip;
          port = infra.translate.localbind.port.http;
          domain = infra.translate.fqdn;
          updateModels = true;
          configureNginx = true;
        };
      };
    };
  };
}
