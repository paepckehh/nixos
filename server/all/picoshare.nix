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
      containers = {
        picoshare = {
          image = "mtlynch/picoshare";
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
