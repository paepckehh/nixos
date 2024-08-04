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
        hostName = "nix-build.lan"; # internal nixos build host/cluster
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUMvSzFybnlXc1kwSmFwbkU5d2d6MGxuYm5reGhuTjhsbU5CT0dwMWlEcGMgbml4YnVpbGRlckBuaXgtYnVpbGQubGFuCg==";
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
