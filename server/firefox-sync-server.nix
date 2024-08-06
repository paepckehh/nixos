{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    mysql.package = pkgs.mariadb;
    firefox-syncserver = {
      enable = true;
      secrets = builtins.toFile "super-secret-sync-secrets" ''SYNC_MASTER_SECRET=nix-store-super-secret'';
      singleNode = {
        enable = true;
        hostname = "ff.lan";
        url = "http://ff.lan:5000";
      };
    };
  };
}
