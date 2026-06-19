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
    autoStart = false;
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
      nixpkgs = {
        config = {
          allowBroken = true;
          allowUnfree = true;
        };
      };

      ##################
      #-=# PROGRAMS #=-#
      ##################
      programs.mosh.enable = true;

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
