# onlyoffice server docker
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
  networking.extraHosts = "${infra.onlyoffice.ip} ${infra.onlyoffice.hostname} ${infra.onlyoffice.fqdn}";

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        onlyoffice = {
          image = "onlyoffice/documentserver";
          ports = ["${infra.localhost.ip}:${toString infra.onlyoffice.localbind.port.http}:80"];
          environment = {
            JWT_SECRET = "gjreopogh3QvVivfdvdbgi3ongjniwveVE";
          };
          volumes = [
            # sudo mkdir -p /var/lib/onlyoffice-docker /var/lib/onlyoffice-docker-db /var/lib/onlyoffice-docker-log /var/lib/onlyoffice-docker-www/onlyoffice/Data
            "/var/lib/onlyoffice-docker:/var/lib/onlyoffice"
            "/var/lib/onlyoffice-docker-db:/var/lib/postgresql"
            "/var/lib/onlyoffice-docker-log:/var/log/onlyoffice"
            "/var/lib/onlyoffice-docker-www/onlyoffice/Data:/var/www/onlyoffice/Data"
          ];
        };
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.onlyoffice.fqdn}" = {
      listenAddresses = [infra.onlyoffice.ip];
      extraConfig = ''import intraproxy ${toString infra.onlyoffice.localbind.port.http}'';
    };
  };
}
