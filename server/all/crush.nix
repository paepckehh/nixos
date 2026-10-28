# crush, cloud
{
  config,
  pkgs,
  lib,
  infra,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.crush.user.ip} ${infra.crush.hostname} ${infra.crush.fqdn}";
    firewall = {
      allowedTCPPorts = [infra.port.ssh-mgmt infra.port.smb.tcp 8080 9090]; # 8080 9090 application test ports
      allowedUDPPorts = [infra.port.smb.quic];
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    tmpfiles.rules = ["d ${infra.storage.projects} 0775 root users"];
    network.networks = {
      "${infra.namespace.admin}".addresses = [{Address = "${infra.crush.admin.ip}/32";}];
      "${infra.namespace.user}".addresses = [{Address = "${infra.crush.user.ip}/32";}];
    };
  };

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers.crush = {
    autoStart = true;
    privateNetwork = false;
    bindMounts."/etc/nixos".isReadOnly = true;
    bindMounts."${infra.storage.projects}".isReadOnly = false;
    bindMounts."${infra.storage.cache}".isReadOnly = false;
    config = {
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
      #################
      #-=# IMPORTS #=-#
      #################
      imports = [
        ../../client/env.nix
        ../../packages/ai.nix
      ];

      ####################
      #-=# NETWORKING #=-#
      ####################
      networking = {
        hostName = infra.crush.hostname;
        firewall = {
          enable = lib.mkForce true;
          allowPing = lib.mkForce true;
          allowedTCPPorts = [infra.port.ssh-mgmt infra.port.smb.tcp 8080 9090]; # 8080 9090 application test ports
          allowedUDPPorts = [infra.port.smb.quic];
        };
      };

      ###############
      #-=# USERS #=-#
      ###############
      users = infra.admin.users;

      #############
      #-=# NIX #=-#
      #############
      nix.settings = {
        experimental-features = ["blake3-hashes" "local-overlay-store" "nix-command" "flakes" "verified-fetches"];
        trusted-users = ["me" "mp" "root"];
      };

      #####################
      #-=# ENVIRONMENT #=-#
      #####################
      environment = {
        systemPackages = with pkgs; [ghostty tmux tuios];
        interactiveShellInit = "TERM=xterm-ghostty /run/current-system/sw/bin/tuios attach ssh_tuios --show-clock --show-cpu --show-ram || TERM=xterm-ghostty /run/current-system/sw/bin/tuios new ssh_tuios --show-clock --show-cpu --show-ram";
        shells = [pkgs.bashInteractive];
        shellAliases = infra.shell.alias;
        sessionVariables = {
          CGO_ENABLED = "0";
          GOAMD64 = "v3";
          GOARCH = "amd64";
          GOPATH = "~/.go";
          GOCACHE = "~/.go-build-cache";
          GOMODCACHE = "/tmp/.go-mod-cache";
          GOFIPS140 = "off";
          GOHOSTARCH = "amd64";
          GOHOSTOS = "linux";
          GOEXPERIMENT = "simd";
          GOOS = "linux";
          GOPROXY = "https://goproxy.dbt.corp,https://proxy.golang.org"; # direct
          GOSUMDB = "sum.golang.org+033de0ae+Ac4zctda0e5eza+HJyk9SxEdh+s3Ux18htTTAD8OuAn8";
          GOTELEMETRY = "off";
          GOTELEMETRYDIR = "/dev/null";
          GOTOOLCHAIN = "auto";
        };
      };

      ##################
      #-=# SERVICES #=-#
      ##################
      services = {
        openssh = {
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
              addr = infra.crush.admin.ip;
              port = infra.port.ssh-mgmt;
            }
          ];
        };
        samba-wsdd.enable = lib.mkForce false;
        samba = {
          enable = false;
          smbd.enable = false;
          nmbd.enable = lib.mkForce false;
          nsswins = lib.mkForce false;
          usershares.enable = lib.mkForce false;
          winbindd.enable = lib.mkForce false;
          settings = {
            global = infra.smb.global;
            "projects" = {
              "path" = "/nix/persist/projects";
              "browseable" = "yes";
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0664";
              "directory mask" = "0775";
              "force user" = "root";
              "force group" = "users";
              "valid users" = ["mp" "tb" "pk" "sw"];
            };
          };
        };
      };
    };
  };
}
