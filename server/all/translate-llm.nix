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
    caddy.virtualHosts."${infra.translate-lama.fqdn}" = {
      listenAddresses = [infra.translate-lama.ip];
      extraConfig = ''
        reverse_proxy ${infra.localhost.ip}:${toString infra.translate-lama.localbind.port.http}
        @not_intranet { not remote_ip ${infra.translate-lama.access.cidr} }
        respond @not_intranet 403'';
    };
  };
}
