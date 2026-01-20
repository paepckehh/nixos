# wiki-go as docker container
# prep:
# mkdir -p /var/lib/wiki-go/data
# sudo chown -R 1000:1000 /var/lib/wiki-go
# optional: edit /var/lib/wiki-go/data/config.yml
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.wiki-go.ip} ${infra.wiki-go.hostname} ${infra.wiki-go.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.wiki-go.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.wiki-go.fqdn}" = {
      listenAddresses = [infra.wiki-go.ip];
      extraConfig = ''import intraproxy ${toString infra.wiki-go.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        wiki-go = {
          image = "leomoonstudios/wiki-go:latest";
          ports = ["${infra.localhost.ip}:${toString infra.wiki-go.localbind.port.http}:8080"];
          volumes = ["/var/lib/wiki-go/data:/wiki/data:rw"];
        };
      };
    };
  };
}
