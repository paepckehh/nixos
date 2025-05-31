{
  ##################
  # VIRTUALISATION #
  ##################
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        netalertx = {
          autoStart = true;
          image = "ghcr.io/jokob-sk/netalertx:latest";
          extraOptions = ["--network=host"];
          environment = {
            TZ = "Europe/Berlin";
            PORT = "20211";
          };
          volumes = [
            "/var/lib/netalertx:/app"
          ];
        };
      };
    };
  };
}
