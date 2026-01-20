{
  pkgs,
  lib,
  config,
  ...
}: {
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };

  # Enable container name DNS for all Podman networks.
  networking.firewall.interfaces = let
    matchAll =
      if !config.networking.nftables.enable
      then "podman+"
      else "podman*";
  in {
    "${matchAll}".allowedUDPPorts = [53];
  };

  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."docmost-db" = {
    image = "postgres:16-alpine";
    environment = {
      "POSTGRES_DB" = "docmost";
      "POSTGRES_PASSWORD" = "STRONG_DB_PASSWORD";
      "POSTGRES_USER" = "docmost";
    };
    volumes = [
      "docmost_db_data:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=db"
      "--network=docmost_default"
    ];
  };
  systemd.services."podman-docmost-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-docmost_default.service"
      "podman-volume-docmost_db_data.service"
    ];
    requires = [
      "podman-network-docmost_default.service"
      "podman-volume-docmost_db_data.service"
    ];
    partOf = [
      "podman-compose-docmost-root.target"
    ];
    wantedBy = [
      "podman-compose-docmost-root.target"
    ];
  };
  virtualisation.oci-containers.containers."docmost-docmost" = {
    image = "docmost/docmost:latest";
    environment = {
      "APP_SECRET" = "REPLACE_WITH_LONG_SECRET";
      "APP_URL" = "http://localhost:3000";
      "DATABASE_URL" = "postgresql://docmost:STRONG_DB_PASSWORD@db:5432/docmost?schema=public";
      "REDIS_URL" = "redis://redis:6379";
    };
    volumes = [
      "docmost_docmost:/app/data/storage:rw"
    ];
    ports = [
      "3000:3000/tcp"
    ];
    dependsOn = [
      "docmost-db"
      "docmost-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=docmost"
      "--network=docmost_default"
    ];
  };
  systemd.services."podman-docmost-docmost" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-docmost_default.service"
      "podman-volume-docmost_docmost.service"
    ];
    requires = [
      "podman-network-docmost_default.service"
      "podman-volume-docmost_docmost.service"
    ];
    partOf = [
      "podman-compose-docmost-root.target"
    ];
    wantedBy = [
      "podman-compose-docmost-root.target"
    ];
  };
  virtualisation.oci-containers.containers."docmost-redis" = {
    image = "redis:7.2-alpine";
    volumes = [
      "docmost_redis_data:/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=redis"
      "--network=docmost_default"
    ];
  };
  systemd.services."podman-docmost-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-docmost_default.service"
      "podman-volume-docmost_redis_data.service"
    ];
    requires = [
      "podman-network-docmost_default.service"
      "podman-volume-docmost_redis_data.service"
    ];
    partOf = [
      "podman-compose-docmost-root.target"
    ];
    wantedBy = [
      "podman-compose-docmost-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-docmost_default" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f docmost_default";
    };
    script = ''
      podman network inspect docmost_default || podman network create docmost_default
    '';
    partOf = ["podman-compose-docmost-root.target"];
    wantedBy = ["podman-compose-docmost-root.target"];
  };

  # Volumes
  systemd.services."podman-volume-docmost_db_data" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect docmost_db_data || podman volume create docmost_db_data
    '';
    partOf = ["podman-compose-docmost-root.target"];
    wantedBy = ["podman-compose-docmost-root.target"];
  };
  systemd.services."podman-volume-docmost_docmost" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect docmost_docmost || podman volume create docmost_docmost
    '';
    partOf = ["podman-compose-docmost-root.target"];
    wantedBy = ["podman-compose-docmost-root.target"];
  };
  systemd.services."podman-volume-docmost_redis_data" = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect docmost_redis_data || podman volume create docmost_redis_data
    '';
    partOf = ["podman-compose-docmost-root.target"];
    wantedBy = ["podman-compose-docmost-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-docmost-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
