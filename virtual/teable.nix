{
  config,
  pkgs,
  ...
}: {
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers = {
        teable = {
          image = "ghcr.io/teableio/teable:latest";
          ports = ["0.0.0.0:8080:8080"];
          environment = {
          };
        };
      };
    };
  };
}
