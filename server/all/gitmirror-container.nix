# git mirror cgit container
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
  networking.extraHosts = "${infra.git-mirror.ip} ${infra.git-mirror.hostname} ${infra.git-mirror.fqdn}.";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.namespace.user}.addresses = [{Address = "${infra.git-mirror.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.git-mirror.fqdn}" = {
      listenAddresses = [infra.git-mirror.ip];
      extraConfig = ''import intraproxy ${toString infra.git-mirror.localbind.port.http}'';
    };
  };

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers.${infra.git-mirror.name} = {
    autoStart = true;
    ephemeral = true;
    bindMounts."/nix/persist/gitmirror".isReadOnly = true;
    privateNetwork = false;
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
      networking.hostName = infra.git-mirror.hostname;

      ##################
      #-=# SERVICES #=-#
      ##################
      services = {
        nginx.virtualHosts."${infra.git-mirror.name}" = {
          forceSSL = false;
          enableACME = false;
          listen = [
            {
              addr = infra.localhost.ip;
              port = infra.portal.localbind.port.http;
            }
          ];
        };
        cgit.${infra.git-mirror.name} = {
          enable = true;
          nginx.virtualHost = "${infra.git-mirror.name}";
          scanPath = infra.storage.gitmirror;
          gitHttpBackend = {
            enable = true;
            checkExportOkFiles = false;
          };
        };
      };
    };
  };
}
