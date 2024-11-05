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
          image = "tobysuch/shifter";
          ports = ["0.0.0.0:4002:4002"];
          volumes = ["/var/shifter:/data"];
          environment = {
            "PORT" = "4002";
          };
        };
      };
    };
  };
}
