{
  config,
  pkgs,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [podman-tui podman-compose docker docker-compose];
  };
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers = {
        speed = {
          image = "openspeedtest/latest:latest";
          ports = ["0.0.0.0:8181:3000"];
          environment = {
            SET_SERVER_NAME = "speed.pvz.lan";
          };
        };
        # nocdb = {
        #  image = "nocdb/nocdb";
        #  ports = ["0.0.0.0:8484:80"];
        # };
        # spot = {
        #  image = "yooooomi/your_spotify_server";
        #  ports = ["0.0.0.0:8585:8080"];
        #};
      };
    };
  };
}
