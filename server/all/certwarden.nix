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
  networking = {
    extraHosts = "${infra.webacme.ip} ${infra.webacme.hostname} ${infra.webacme.fqdn}.";
    firewall.allowedTCPPorts = infra.webacme.port;
  };

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
    caddy = {
      enable = true;
      virtualHosts = {
        "${infra.webacme.fqdn}".extraConfig = ''
          bind ${infra.webacme.ip}
          reverse_proxy ${infra.localhost.ip}:${toString infra.webacme.localbind.port.http}
          tls ${infra.pki.acme.contact} {
                ca_root ${infra.pki.certs.rootCA.path}
                ca ${infra.pki.acme.url}
          }
          @not_intranet {
            not remote_ip ${infra.webacme.access.cidr}
          }
          respond @not_intranet 403
          log {
            output file ${config.services.caddy.logDir}/access/${infra.webacme.name}.log
          }'';
      };
    };
  };
}
