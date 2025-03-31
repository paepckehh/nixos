{
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    openssh = {
      enable = true; # needed to generate uniq hostKeys
      allowSFTP = false;
      authorizedKeysCommand = "none";
      authorizedKeysCommandUser = "nobody";
      authorizedKeysFiles = [];
      authorizedKeysInHomedir = false;
      banner = null;
      extraConfig = "";
      hostKeys = {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
        rounds = 1000;
      };
      knownHosts = [];
      listenAddresses = {
        addr = "127.0.0.1";
        porst = 64022;
      };
      moduliFile = null;
      openFirewall = false;
      settings = {
        AllowGroups = null;
        AllowUsers = null;
        AuthorizedPrincipalsFile = none;
        Ciphers = ["chacha20-poly1305@openssh.com"];
        DenyGroups = null;
        DenyUsers = null;
        Gatewayports = "no";
        KbdInteractiveAuthentication = false;
        KexAlgorithms = ["curve25519-sha256" "curve25519-sha256@libssh.org"];
        LogLevel = "Info";
        Macs = null; # chacha20-poly1305 inherent
        PermitRootLogin = "no";
        PrintMotd = "false";
        StrictModes = true;
        UseDNS = false;
        UsePam = false;
        X11Forwarding = false;
        sftpFlags = [];
        sftpServerExecuteable = "";
        startWhenNeeded = true;
        enableSrunX11 = false;
      };
    };
  };
}
