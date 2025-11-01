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
    extraHosts = "${infra.translate-lama.ip} ${infra.translate-lama.hostname} ${infra.translate-lama.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    ollama = {
      enable = true;
      host = infra.localhost.ip;
      port = infra.translate-lama.localbind.port.http;
      # models = "";
      # loadModels = [];
    };
    caddy = {
      enable = true;
      virtualHosts = {
        "${infra.translate-lama.fqdn}".extraConfig = ''
          bind ${infra.translate-lama.ip}
          reverse_proxy ${infra.localhost.ip}:${toString infra.translate-lama.localbind.port.http}
          tls ${infra.pki.acme.contact} {
                ca_root ${infra.pki.certs.rootCA.path}
                ca ${infra.pki.acme.url}
          }
          @not_intranet {
            not remote_ip ${infra.translate-lama.access.cidr}
          }
          respond @not_intranet 403
          log {
            output file ${config.services.caddy.logDir}/access/${infra.translate-lama.name}.log
          }'';
      };
    };
  };
}
