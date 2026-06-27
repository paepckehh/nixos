# crush, cloud
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
  networking.extraHosts = "${infra.crush.ip} ${infra.crush.hostname} ${infra.crush.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.crush.ip}/32";}];

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers.crush = {
    autoStart = true;
    privateNetwork = false;
    bindMounts."${infra.me.projects}".isReadOnly = false;
    bindMounts."${infra.storage.cache}".isReadOnly = false;
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      #################
      #-=# IMPORTS #=-#
      #################
      imports = [
        ../../client/env.nix
        ../../packages/ai.nix
        ../../packages/tmux.nix
        ../../packages/base.nix
        ../../packages/devops-go.nix
        ../../packages/devops-python.nix
        ../../packages/devops-html.nix
        ../../packages/devops-nixos.nix
      ];
      ####################
      #-=# NETWORKING #=-#
      ####################
      networking.hostName = infra.crush.hostname;

      ###############
      #-=# USERS #=-#
      ###############
      users = infra.admin.users;

      #####################
      #-=# ENVIRONMENT #=-#
      #####################
      environment = {
        # systemPackages = with pkgs; [];
        interactiveShellInit = "TERM=xterm-256color /run/current-system/sw/bin/tmux attach-session -t ssh_tmux || TERM=xterm-256color /run/current-system/sw/bin/tmux new-session -s ssh_tmux";
        shells = [pkgs.bashInteractive pkgs.fish];
        shellAliases = infra.shellAliases;
        variables = infra.go.env;
      };

      ##################
      #-=# PROGRAMS #=-#
      ##################
      programs = {
        bat.enable = true;
        vim.enable = true;
        starship = {
          enable = true;
          transientPrompt.enable = true;
        };
        git = {
          enable = true;
          config = infra.git.client.conf;
        };
      };

      ##################
      #-=# SERVICES #=-#
      ##################
      services.openssh = {
        enable = lib.mkDefault true;
        settings = infra.sshd.settings;
        authorizedKeysInHomedir = false;
        allowSFTP = false;
        ports = [infra.port.ssh-mgmt];
        startWhenNeeded = false;
        generateHostKeys = true;
        hostKeys = lib.mkForce [
          {
            path = "/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
        listenAddresses = lib.mkForce [
          {
            addr = infra.crush.ip;
            port = infra.port.ssh-mgmt;
          }
        ];
      };
    };
  };
}
