{
  ##################
  # VIRTUALISATION #
  ##################
  services.nginx.enable = true; # create user/group
  virtualisation = {
    oci-containers = {
      containers = {
        netalertx = {
          autoStart = true;
          image = "ghcr.io/jokob-sk/netalertx:latest";
          extraOptions = ["--network=host"];
          environment = {
            TZ = "Europe/Berlin";
            LISTEN_ADDR = "127.0.0.1";
            PORT = "20211";
            PGUI = "60";
            PGID = "60";
          };
          volumes = [
            "/var/lib/netalertx/api:/app/api"
            "/var/lib/netalertx/config:/app/config"
            "/var/lib/netalertx/db:/app/db"
          ];
        };
      };
    };
  };
}
