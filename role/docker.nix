# generic server docker backend base setup
{
  config,
  pkgs,
  lib,
  infra,
  ...
}: {
  ##############
  #-=# USER #=-#
  ##############
  users.users.me.extraGroups = ["docker" "libvirtd"];

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers.backend = "docker";
    docker = {
      enable = true;
      daemon.settings = {
        experimental = true;
        dns = [infra.dns.resolver.user.primary infra.dns.resolver.user.secondary];
        log-driver = "journald";
        storage-driver = "overlay2";
        default-address-pools = [
          {
            base = infra.cidr.container;
            size = infra.cidr.netmask;
          }
        ];
      };
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
