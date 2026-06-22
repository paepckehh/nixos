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

      ##################
      #-=# PROGRAMS #=-#
      ##################
      programs.mosh.enable = true;

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
              ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIG50evljqeCBDwrkkB0FXf9A2BtCKYnDYHOnHZvpmRLNAAAABHNzaDo= me@ops''
            ];
          };
        };
      };

      ##################
      #-=# PROGRAMS #=-#
      ##################
      programs = {
        fish.enable = true;
        vim.enable = true;
        git = {
          enable = true;
          config = infra.git.client.conf;
        };
        tmux = {
          enable = true;
          clock24 = true;
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
      environment = {
        variables = {
          CGO_ENABLED = "0";
          GOAMD64 = "v3";
          GOARCH = "amd64";
          GOAUTH = lib.mkForce "";
          GOCACHE = lib.mkForce "/nix/persist/cache/go/cache";
          GOEXPERIMENT = "";
          GOFIPS140 = "off";
          GOHOSTARCH = "amd64";
          GOHOSTOS = "linux";
          GOINSECURE = lib.mkForce "";
          GOMOD = lib.mkForce "/dev/null";
          GOMODCACHE = lib.mkForce "/nix/persist/cache/go/pkg/mod";
          GONOPROXY = lib.mkForce "";
          GONOSUMDB = lib.mkForce "";
          GOOS = "linux";
          GOPATH = lib.mkForce ["/nix/persist/cache/go/go-path"];
          GOPRIVATE = lib.mkForce "";
          GOPROXY = lib.mkForce "https://proxy.golang.org"; # direct
          GOSUMDB = lib.mkForce "sum.golang.org+033de0ae+Ac4zctda0e5eza+HJyk9SxEdh+s3Ux18htTTAD8OuAn8";
          GOTELEMETRY = lib.mkForce "off";
          GOTELEMETRYDIR = lib.mkForce "/dev/null";
          GOTOOLCHAIN = lib.mkForce "auto";
          GOVCS = lib.mkForce "";
          GOWORK = lib.mkForce "";
        };
      };
    };
  };
}
