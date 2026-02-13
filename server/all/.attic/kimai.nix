# kimai
# sudo bash
# cd /nix/store/<hash>-kimai-<yoursite>-2.40.0/bin/
# sudo -u kimai ./console  kimai:user:create -- admin admin@adm.corp ROLE_SUPER_ADMIN
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
  networking.extraHosts = "${infra.kimai.ip} ${infra.kimai.hostname} ${infra.kimai.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.kimai.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.kimai.fqdn}" = {
      listenAddresses = [infra.kimai.ip];
      extraConfig = ''import intraproxy ${toString infra.kimai.localbind.port.http}'';
    };
    kimai.sites."${infra.kimai.name}".database.createLocally = true;
    nginx.virtualHosts."${infra.kimai.name}".listen = [
      {
        addr = infra.localhost.ip;
        port = infra.kimai.localbind.port.http;
      }
    ];
  };
}
