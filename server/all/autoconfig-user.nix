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
  networking.extraHosts = "${infra.autoconfig.ip} ${infra.autoconfig.hostname} ${infra.autoconfig.fqdn}";

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
        domain = infra.autoconfig.user.fqdn;
        service_addr = "${infra.localhost.ip}:${toString infra.autoconfig.localbind.port.http}";
        imap = {
          server = infra.imap.user.fqdn;
          port = infra.port.imap;
          socketType = infra.autoconfig.user.auth.socketType;
          authentication = infra.autoconfig.user.auth.authentication;
          userid = infra.autoconfig.user.auth.id;
        };
        smtp = {
          server = infra.smtp.user.fqdn;
          port = infra.port.smtp;
          socketType = infra.autoconfig.user.auth.socketType;
          authentication = infra.autoconfig.user.auth.authentication;
          userid = infra.autoconfig.user.auth.id;
        };
      };
    };
    caddy.virtualHosts."${infra.autoconfig.fqdn}" = {
      listenAddresses = [infra.autoconfig.ip];
      extraConfig = ''import intraproxy ${toString infra.autoconfig.localbind.port.http}'';
    };
  };
}
