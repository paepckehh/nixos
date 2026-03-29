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

      ##################
      #-=# PROGRAMS #=-#
      ##################
      programs.git = {
        enable = true;
        prompt.enable = true;
        config = {
          branch.sort = "-committerdate";
          commit.gpgsign = false;
          init.defaultBranch = "main";
          safe.directory = "*";
          gpg.format = "ssh";
          http = {
            sslVerify = "true";
            sslVersion = "tlsv1.3";
            version = "HTTP/1.1";
          };
          protocol = {
            allow = "always";
            file.allow = "always";
            git.allow = "never";
            ssh.allow = "always";
            http.allow = "never";
            https.allow = "always";
          };
        };
      };

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
              port = infra.git-mirror.localbind.port.http;
            }
          ];
        };
        cgit.${infra.git-mirror.name} = {
          enable = true;
          nginx.virtualHost = "${infra.git-mirror.name}";
          scanPath = infra.git-mirror.storage;
          settings = {
            clone-url = "${infra.git-mirror.url}/$CGIT_REPO_URL";
            snapshots = "all";
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
