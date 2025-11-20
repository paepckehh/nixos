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
        domain = infra.autoconfig.fqdn;
        service_addr = "${infra.localhost.ip}:${toString infra.autoconfig.localbind.port.http}";
        imap = {
          server = infra.imap.admin.fqdn;
          port = infra.port.imap;
          socketType = infra.autoconfig.auth.socketType;
          authentication = infra.autoconfig.auth.authentication;
          userid = infra.autoconfig.auth.id;
        };
        smtp = {
          server = infra.smtp.admin.fqdn;
          port = infra.port.smtp;
          socketType = infra.autoconfig.auth.socketType;
          authentication = infra.autoconfig.auth.authentication;
          userid = infra.autoconfig.auth.id;
        };
      };
    };
    caddy.virtualHosts."${infra.autoconfig.fqdn}" = {
      listenAddresses = [infra.autoconfig.ip];
      extraConfig = ''
        reverse_proxy ${infra.localhost.ip}:${toString infra.autoconfig.localbind.port.http}
        @not_intranet { not remote_ip ${infra.cloud.access.cidr} }
        respond @not_intranet 403'';
    };
  };
}
