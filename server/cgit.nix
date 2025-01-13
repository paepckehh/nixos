{
  config,
  pkgs,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    hosts."127.0.0.80" = ["git.localnet"];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    cgit = {
      "git.localnet" = {
        enable = true;
        scanPath = "/var/repo";
        nginx.virtualHost = "git.localnet";
      };
    };
  };
}
