{
  config,
  pkgs,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    mysql.package = pkgs.mariadb;
    firefox-syncserver = {
      enable = true;
      secrets = builtins.toFile "sync-secrets" ''
        SYNC_MASTER_SECRET=mkvmekqPUBLICmvke3cmld
      '';
      singleNode = {
        enable = true;
        hostname = "localhost";
        url = "http://localhost:5000";
      };
    };
  };
}
