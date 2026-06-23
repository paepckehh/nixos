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
      users = {
        groups.mp.gid = infra.me.uid;
        users = {
          mp = {
            description = "mp crush user";
            group = "mp";
            uid = infra.mp.uid;
            createHome = true;
            isNormalUser = true;
            shell = pkgs.fish;
            extraGroups = ["users" "wheel"];
            hashedPassword = lib.mkForce "$y$j9T$--fail--"; # enable user, disable password login hash match
            openssh.authorizedKeys.keys = lib.mkForce [
              ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIG50evljqeCBDwrkkB0FXf9A2BtCKYnDYHOnHZvpmRLNAAAABHNzaDo=''
            ];
          };
        };
      };

      ##################
      #-=# PROGRAMS #=-#
      ##################
      programs = {
        bat.enable = true;
        vim.enable = true;
        fish = {
          enable = true;
          shellInit = "TERM=xterm-256color /run/current-system/sw/bin/tmux attach-session -t ssh_tmux || TERM=xterm-256color /run/current-system/sw/bin/tmux new-session -s ssh_tmux";
        };
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

      #####################
      #-=# ENVIRONMENT #=-#
      #####################
      environment.variables = infra.go.env;
    };
  };
}
