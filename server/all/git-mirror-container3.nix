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

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.git-mirror.fqdn}" = {
      listenAddresses = [infra.git-mirror.ip];
      extraConfig = ''import intraproxy ${toString infra.git-mirror.localbind.port.http}'';
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.git-mirror.ip}/32";}];

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers."${infra.git-mirror.name}" = {
    autoStart = true;
    ephemeral = true;
    bindMounts."${infra.git-mirror.storage}".isReadOnly = true;
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

      #################
      #-=# SYSTEMD #=-#
      #################
      systemd.tmpfiles.rules = ["d /var/run/cgit 0775 cgit cgit"];

      ##################
      #-=# PROGRAMS #=-#
      ##################
      programs.git = {
        enable = true;
        config = infra.git.client.conf;
      };

      ##################
      #-=# SERVICES #=-#
      ##################
      services = {
        gitweb.projectroot = infra.git-mirror.storage;
        nginx = {
          enable = true;
          gitweb = {
            enable = true;
            virtualHost = infra.git-mirror.name;
          };
          virtualHosts."${infra.git-mirror.name}" = {
            forceSSL = false;
            enableACME = false;
            listen = [
              {
                addr = infra.localhost.ip;
                port = infra.git-mirror.localbind.port.http;
              }
            ];
            extraConfig = ''
              client_header_timeout  8m;
              client_body_timeout    8m;
              send_timeout           8m;
            '';
          };
        };
      };
    };
  };
}
