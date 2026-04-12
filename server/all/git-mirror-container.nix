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
        nginx.virtualHosts."${infra.git-mirror.name}" = {
          forceSSL = false;
          enableACME = false;
          # locations."/".fastcgiParams = "";
          listen = [
            {
              addr = infra.localhost.ip;
              port = infra.git-mirror.localbind.port.http;
            }
          ];
          extraConfig = ''
            fastcgi_read_timeout   1000s;
            client_header_timeout  1000s;
            client_body_timeout    1000s;
            send_timeout           1000s;
          '';
        };
        cgit.${infra.git-mirror.name} = {
          enable = true;
          nginx.virtualHost = "${infra.git-mirror.name}";
          scanPath = infra.git-mirror.storage;
          settings = {
            clone-url = "${infra.git-mirror.url}/$CGIT_REPO_URL";
            snapshots = "all";
            cache-size = 2000;
            cache-root = "/var/run/cgit";
          };
          gitHttpBackend = {
            enable = true;
            checkExportOkFiles = false;
          };
        };
      };
    };
  };
}
