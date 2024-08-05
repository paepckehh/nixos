{
  config,
  pkgs,
  lib,
  ...
}: {
  #############
  #-=# NIX #=-#
  #############
  nix = {
    settings = {
      allowed-uris = lib.mkForce [
        "http://nix-build.lan"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      substituters = lib.mkForce [
        "http://nix-build.lan"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = lib.mkForce [
        "nix-build.lan:T7R9J0KEfVCH5XTX8MUHvR9to7suYeVD9B7fpswfpho="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "nix-build.lan"; # internal nixos build host/cluster
        systems = ["x86_64-linux"];
        protocol = "ssh";
        sshUser = "nixbuilder";
        sshKey = "/home/me/.ssh/id_nixbuilder";
        maxJobs = 1;
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      }
    ];
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    hosts = {"192.168.8.99" = ["nix-build.lan" "nix-build"];};
  };
}
