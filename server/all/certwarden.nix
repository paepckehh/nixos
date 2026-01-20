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

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.webacme.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.webacme.fqdn}" = {
      listenAddresses = [infra.webacme.ip];
      extraConfig = ''import intraproxy ${toString infra.webacme.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
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
}
