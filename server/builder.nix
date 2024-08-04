{
  config,
  pkgs,
  lib,
  ...
}: {
  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      nixbuilder = {
        description = "sandboxed nixbuilder";
        uid = 64500;
        group = "users";
        createHome = true;
        isNormalUser = true;
        hashedPassword = null; # disable interactive authentication
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/K1rnyWsY0JapnE9wgz0lnbnkxhnN8lmNBOGp1iDpc nixbuilder@nix-build.lan"];
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    endlessh-go = {
      enable = false;
      openFirewall = true;
      port = 22;
      listenAddress = "0.0.0.0";
      prometheus = {
        enable = false;
        port = 9119;
        listenAddress = "0.0.0.0";
      };
    };
    openssh = {
      enable = lib.mkForce true;
      allowSFTP = false;
      settings = {
        AllowUsers = ["nixbuilder"];
        AllowAgentForwarding = false;
        AllowStreamLocalForwarding = false;
        AllowTcpForwarding = false;
        AuthenticationMethods = "publickey";
        ChallengeResponseAuthentication = false;
        Ciphers = ["chacha20-poly1305@openssh.com"]; # legacy: "aes256-gcm@openssh.com"
        KexAlgorithms = ["curve25519-sha256"]; # legacy: "diffie-hellman-group-exchange-sha256" "...@libssh.org"
        StrictModes = true;
        LogLevel = "INFO";
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        UseDns = false;
        UsePAM = false;
        X11Forwarding = false;
      };
      startWhenNeeded = true;
      hostKeys = [
        {
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
        }
      ];
      openFirewall = true;
      listenAddresses = [
        {
          port = 22;
          addr = "0.0.0.0";
        }
      ];
    };
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    ssh = {
      knownHosts = {
        nix-build = {
          extraHostNames = ["nix-build.lan"];
          publicKey = "";
        };
      };
    };
  };
}
