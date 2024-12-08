{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    firefox-syncserver = {
      enable = true;
      secrets = builtins.toFile "super-secret-sync-secrets" ''SYNC_MASTER_SECRET=nix-store-super-secret'';
      singleNode = {
        enable = true;
        hostname = "localhost";
        url = "http://localhost:5000";
      };
    };
  };
}
