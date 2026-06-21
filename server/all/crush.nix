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

      #####################
      #-=# ENVIRONMENT #=-#
      #####################
      environment.systemPackages = with pkgs; [crush];

      #################
      #-=# NIXPKGS #=-#
      #################
      nixpkgs.config.allowUnfree = true;

      ##################
      #-=# PROGRAMS #=-#
      ##################
      programs.mosh.enable = true;

      ###############
      #-=# USERS #=-#
      ###############
      users = {
        groups.mp = {};
        users = {
          mp = {
            initialHashedPassword = null; # lockdown, use smardcard only
            description = "mp crush user";
            group = "mp";
            createHome = true;
            isNormalUser = true;
            shell = pkgs.fish;
            extraGroups = ["users" "wheel"];
            openssh.authorizedKeys.keys = lib.mkForce [
              "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIG50evljqeCBDwrkkB0FXf9A2BtCKYnDYHOnHZvpmRLNAAAABHNzaDo= me@ops"
            ];
          };
        };
      };

      ##################
      #-=# SERVICES #=-#
      ##################
      services.openssh = {
        enable = lib.mkDefault true;
        settings = infra.ssh.settings;
        authorizedKeysInHomedir = false;
        allowSFTP = false;
        ports = [infra.port.ssh-mgmt];
        startWhenNeeded = true;
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
