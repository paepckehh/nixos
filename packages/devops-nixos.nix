{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [
    disko
    nixfmt
    nix-init
    nixpkgs-review
    nix-prefetch-scripts
    nix-search-cli
    nfs-utils
    parted
    zfs
  ];
}
