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
    lighttpd.cgit = {
      enable = true;
      configText = ''
        enable-commit-graph=1
        enable-follow-links=1
        enable-http-clone=1
        enable-index-links=1
        enable-remote-branches=1
        clone-url=http://git.localnet/$CGIT_REPO_URL
        remove-suffix=1
        root-title=http://git.localnet
        root-desc=local git repo store path: /var/repo
        scanPath=/var/repo
        snapshots=all'';
    };
  };
}
