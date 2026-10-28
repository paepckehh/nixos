{
  lib,
  infra,
  ...
}:
lib.mkMerge [
  (import ../../lib/proxy.nix {
    inherit infra;
    name = "bentopdf";
  })
  {
    ########################
    #-=# VIRTUALISATION #=-#
    ########################
    virtualisation = {
      oci-containers = {
        containers = {
          bentopdf = {
            image = "ghcr.io/alam00000/bentopdf:latest";
            ports = ["${infra.localhost.ip}:${toString infra.bentopdf.localbind.port.http}:8080"];
            environment.SET_SERVER_NAME = "${infra.bentopdf.fqdn}";
          };
        };
      };
    };
  }
]
