# Monitoring, Kuma, Status
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
  networking.extraHosts = "${infra.kuma.ip} ${infra.kuma.hostname} ${infra.kuma.fqdn}.";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.kuma.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.kuma.fqdn}" = {
      listenAddresses = [infra.kuma.ip];
      extraConfig = ''import intraproxy ${toString infra.kuma.localbind.port.http}'';
    };
    uptime-kuma = {
      enable = true;
      appriseSupport = false;
      settings = {
        UPTIME_KUMA_HOST = infra.localhost.ip;
        UPTIME_KUMA_PORT = "${toString infra.kuma.localbind.ports.http}";
      };
    };
  };
}
