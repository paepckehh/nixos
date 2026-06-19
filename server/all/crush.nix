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
      networking = {
        hostName = infra.crush.hostname;
        firewall = {
          allowedUDPPortRanges = [
            {
              from = 61001;
              to = 61999;
            }
          ];
        };
      };

      #####################
      #-=# ENVIRONMENT #=-#
      #####################
      environment = {
        systemPackages = with pkgs; [
          tsshd
          crush
        ];
        etc."ssh/sshd_config".text = ''
          AddressFamily inet
          AllowAgentForwarding no
          AllowUsers me
          AuthenticationMethods publickey
          AuthorizedPrincipalsFile none
          ChallengeResponseAuthentication no
          Ciphers chacha20-poly1305@openssh.com
          ClientAliveCountMax 3
          ClientAliveInterval 30
          Compression no
          GatewayPorts no
          HostKey /etc/ssh/ssh_host_ed25519_key
          KbdInteractiveAuthentication no
          KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
          LogLevel INFO
          LoginGraceTime 2m
          MaxStartups 10:30:100
          PasswordAuthentication no
          PerSourceMaxStartups 12
          PerSourceNetBlockSize 32:128
          PermitRootLogin no
          PrintMotd no
          PubkeyAuthOptions touch-required
          PubkeyAuthentication yes
          RekeyLimit 512M, 1h
          StrictModes yes
          UseDns no
          UsePAM no
          X11Forwarding no
          AddressFamily inet
          ListenAddress 10.20.0.100:6623
          AuthorizedKeysFile /etc/ssh/authorized_keys.d/%u
          HostKey /etc/ssh/ssh_host_ed25519_key
        '';
      };

      #################
      #-=# NIXPKGS #=-#
      #################
      nixpkgs = {
        config = {
          allowBroken = true;
          allowUnfree = true;
        };
      };

      #################
      #-=# SYSTEMD #=-#
      #################
      systemd = {
        services.tsshd = {
          after = ["network.target"];
          wantedBy = ["multi-user.target"];
          description = "modern resumeable sshd replacement";
          serviceConfig = {
            ExecStart = "${pkgs.tsshd}/bin/tsshd";
            KillMode = "process";
            Restart = "always";
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
              "AF_UNIX"
            ];
          };
        };
      };
    };
  };
}
