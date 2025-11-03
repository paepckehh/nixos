# WEBACME => CERTWARDEN: acme client web gui, admin, password
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/home.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.webacme.ip} ${infra.webacme.hostname} ${infra.webacme.fqdn}.";

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        certwarden = {
          autoStart = true;
          hostname = infra.webacme.fqdn;
          image = "ghcr.io/gregtwallace/certwarden:latest";
          ports = [
            "${infra.localhost.ip}:${toString infra.webacme.localbind.port.http}:4050"
          ];
        };
      };
    };
  };

  #################
  #-=# SERVICE #=-#
  #################
  services = {
    caddy.virtualHosts."${infra.webacme.fqdn}" = {
      listenAddresses = [infra.webacme.ip];
      extraConfig = ''
        reverse_proxy ${infra.localhost.ip}:${toString infra.webacme.localbind.port.http}
        @not_intranet { not remote_ip ${infra.webacme.access.cidr} }
        respond @not_intranet 403'';
    };
  };
}
