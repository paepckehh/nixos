{
  lib,
  infra,
  ...
}:
lib.mkMerge [
  (import ../../lib/proxy.nix {
    inherit infra;
    name = "chef";
  })
  {
    ########################
    #-=# VIRTUALISATION #=-#
    ########################
    virtualisation = {
      oci-containers = {
        containers = {
          chef = {
            image = "ghcr.io/gchq/cyberchef:latest";
            ports = ["${infra.localhost.ip}:${toString infra.chef.localbind.port.http}:8080"];
            environment.SET_SERVER_NAME = "${infra.chef.fqdn}";
          };
        };
      };
    };
  }
]
