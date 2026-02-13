# kimai
# sudo bash
# nixos-container root-login kimai
# cd /nix/store/<hash>-kimai-<yoursite>-2.40.x/bin/
# sudo -u kimai ./console  kimai:user:create -- admin admin@adm.corp ROLE_SUPER_ADMIN
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
  networking.extraHosts = "${infra.kimai.ip} ${infra.kimai.hostname} ${infra.kimai.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.kimai.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.kimai.fqdn}" = {
      listenAddresses = [infra.kimai.ip];
      extraConfig = ''import intraproxy ${toString infra.kimai.localbind.port.http}'';
    };
  };

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers.${infra.kimai.name} = {
    autoStart = true;
    privateNetwork = false;
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      ################
      #-=# SYSTEM #=-#
      ################
      system.stateVersion = "26.05";

      #################
      #-=# IMPORTS #=-#
      #################
      imports = [../../client/env.nix];

      ####################
      #-=# NETWORKING #=-#
      ####################
      networking.hostName = infra.kimai.hostname;

      ##################
      #-=# SERVICES #=-#
      ##################
      services = {
        kimai.sites."${infra.kimai.name}".database.createLocally = true;
        nginx.virtualHosts."${infra.kimai.name}".listen = [
          {
            addr = infra.localhost.ip;
            port = infra.kimai.localbind.port.http;
          }
        ];
      };
    };
  };
}
