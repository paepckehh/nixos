{lib, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    openssh = {
      enable = lib.mkForce true; # needed to generate uniq hostKeys
      allowSFTP = lib.mkForce false;
      authorizedKeysCommand = "none";
      authorizedKeysCommandUser = "nobody";
      authorizedKeysFiles = [""];
      authorizedKeysInHomedir = false;
      banner = null;
      extraConfig = "";
      hostKeys = lib.mkForce [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
          rounds = 1000;
        }
      ];
      listenAddresses = lib.mkForce [
        {
          addr = "127.0.0.1";
          port = 22;
        }
      ];
      openFirewall = false;
      settings = {
        AllowGroups = null;
        AllowUsers = null;
        AuthorizedPrincipalsFile = null;
        Ciphers = ["chacha20-poly1305@openssh.com"];
        DenyGroups = null;
        DenyUsers = null;
        GatewayPorts = "no";
        KbdInteractiveAuthentication = false;
        KexAlgorithms = ["curve25519-sha256" "curve25519-sha256@libssh.org"];
        LogLevel = "VERBOSE"; # INFO, DEBUG
        Macs = null; # chacha20-poly1305 inherent
        PermitRootLogin = "no";
        PrintMotd = false;
        StrictModes = true;
        UseDns = false;
        UsePAM = false;
        X11Forwarding = false;
        # startWhenNeeded = true;
      };
    };
  };
}
