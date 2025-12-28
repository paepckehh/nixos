# autoconfigure email imap smtp thunderbird
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
  networking.extraHosts = "${infra.autoconfig.admin.ip} ${infra.autoconfig.hostname} ${infra.autoconfig.admin.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.go-autoconfig = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    go-autoconfig = {
      enable = true;
      settings = {
        domain = infra.autoconfig.admin.fqdn;
        service_addr = "${infra.localhost.ip}:${toString infra.autoconfig.localbind.port.http}";
        imap = {
          server = infra.imap.admin.fqdn;
          port = infra.port.imap;
          socketType = infra.autoconfig.admin.auth.socketType;
          authentication = infra.autoconfig.admin.auth.authentication;
          userid = infra.autoconfig.admin.auth.id;
        };
        smtp = {
          server = infra.smtp.admin.fqdn;
          port = infra.port.smtp;
          socketType = infra.autoconfig.admin.auth.socketType;
          authentication = infra.autoconfig.admin.auth.authentication;
          userid = infra.autoconfig.admin.auth.id;
        };
      };
    };
    caddy.virtualHosts."${infra.autoconfig.admin.fqdn}" = {
      listenAddresses = [infra.autoconfig.admin.ip];
      extraConfig = ''import intraproxy ${toString infra.autoconfig.localbind.port.http}'';
    };
  };
}
