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
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    endless-go = {
      enable = true;
      openFirewall = true;
      port = 22;
      listenAddress = "0.0.0.0";
      prometheus = {
        enable = true;
        port = 9119;
        listenAddress = "0.0.0.0";
      };
    };
    openssh = {
      enable = lib.mkForce true;
      allowSFTP = false;
      settings = {
        AllowUsers = "nixbuilder";
        AllowAgentForwarding = false;
        AllowStreamLocalForwarding = false;
        AllowTcpForwarding = false;
        AuthenticationMethods = "publickey";
        ChallengeResponseAuthentication = false;
        Ciphers = ["chacha20-poly1305@openssh.com"]; # legacy: "aes256-gcm@openssh.com"
        KexAlgorithms = ["curve25519-sha256" "curve25519-sha256@libssh.org"]; # legacy: "diffie-hellman-group-exchange-sha256"
        StrictModes = true;
        LogLevel = "Info"; # IDS
        PasswordAuthentication = false;
        PermitRootLogin = false;
        UseDns = false;
        UsePam = false;
        X11Forwarding = false;
      };
      startWhenNeeded = true;
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
      openFireWall = true;
      listenAddresses = [
        {
          addr = "0.0.0.0";
          port = "8822";
        }
      ];
    };
  };
}
