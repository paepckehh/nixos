{
  config,
  pkgs,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # environment.systemPackages = with pkgs; [podman-tui podman-compose docker docker-compose compose2nix];

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        timeoff = {
          image = "aliengen/timeoff-management-application:master";
          ports = ["3000:3000"];
        };
      };
    };
  };
}
