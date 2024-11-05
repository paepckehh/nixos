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
        picoshare = {
          image = "";
          ports = ["0.0.0.0:4001:4001"];
          volumes = ["/var/pico:/data"];
          environment = {
            "PORT" = "4001";
            "PS_SHARED_SECRET" = "start";
          };
        };
      };
    };
  };
}
