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
    distributedBuilds = true;
    buildMachines = [
      {
        # publicHostKey = null;
        hostName = "nix-build.lan"; # internal nixos build host/cluster
        systems = ["x86_64-linux"];
        protocol = "ssh-ng";
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
