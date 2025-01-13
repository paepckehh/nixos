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
        settings = {
          enable-commit-graph = true;
          enable-follow-links = true;
          enable-http-clone = true;
          enable-remote-branches = true;
          clone-url = "http://git.localnet/$CGIT_REPO_URL";
          remove-suffix = true;
          root-title = "http://git.localnet";
          root-desc = "local git repo store path: /var/repo";
          snapshots = "all";
        };
        nginx.virtualHost = "git.localnet";
      };
    };
  };
}
