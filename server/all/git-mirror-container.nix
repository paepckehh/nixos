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
  systemd = {
    network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.git-mirror.ip}/32";}];
    services = {
      "git-mirror-gc" = {
        description = "git-mirror-gc";
        startAt = [
          "*-*-* 04:00:00"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/git-mirror-gc.sh";
        };
      };
      "git-mirror-fetch" = {
        description = "git-mirror-fetch";
        startAt = [
          "*-*-* 01:40:00"
          "*-*-* 03:40:00"
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/git-mirror-fetch.sh";
        };
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.etc = {
    "scripts/git-mirror-gc.sh".text = ''
      #/bin/sh
      export GIT="/run/current-system/sw/bin/git"
      export OPT1="--aggressive"
      export OPT2="--keep-largest"
      export MIRROR="/nix/persist/cache/git-mirror"
      /run/current-system/sw/bin/chown -R 0:0 "$MIRROR" || exit 1
      $GIT -C "$MIRROR/paepckehh/nixos" gc "$OPT1"
      $GIT -C "$MIRROR/ryantm/agenix" gc "$OPT1"
      $GIT -C "$MIRROR/nix-community/disko" gc "$OPT1"
      $GIT -C "$MIRROR/nix-community/home-manager" gc "$OPT1"
      $GIT -C "$MIRROR/nixos/nixpkgs" gc "$OPT1" "$OPT2"
    '';
    "scripts/git-mirror-fetch.sh".text = ''
      #/bin/sh
      export GIT="/run/current-system/sw/bin/git"
      export MIRROR="/nix/persist/cache/git-mirror"
      /run/current-system/sw/bin/chown -R 0:0 "$MIRROR" || exit 1
      $GIT -C "$MIRROR/paepckehh/nixos" fetch
      $GIT -C "$MIRROR/ryantm/agenix" fetch
      $GIT -C "$MIRROR/nix-community/disko" fetch
      $GIT -C "$MIRROR/nix-community/home-manager" fetch
      $GIT -C "$MIRROR/nixos/nixpkgs" fetch
    '';
  };

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
            enable-remote-branches = true;
            enable-git-config = true;
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
