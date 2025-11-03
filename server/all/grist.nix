# grist, airtable
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
  networking.extraHosts = "${infra.grist.ip} ${infra.grist.hostname} ${infra.grist.fqdn}.";

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        grist = {
          autoStart = true;
          hostname = infra.grist.fqdn;
          image = "gristlabs/grist";
          ports = ["${infra.localhost.ip}:${toString infra.grist.localbind.port.http}:8484"];
        };
      };
    };
  };

  #################
  #-=# SERVICE #=-#
  #################
  services = {
    caddy.virtualHosts."${infra.grist.fqdn}" = {
      listenAddresses = [infra.grist.ip];
      extraConfig = ''
        reverse_proxy ${infra.localhost.ip}:${toString infra.grist.localbind.port.http}
        @not_intranet { not remote_ip ${infra.grist.access.cidr} }
        respond @not_intranet 403'';
    };
  };
}
