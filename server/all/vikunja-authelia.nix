# vikunja
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
  networking.extraHosts = "${infra.vikunja.ip} ${infra.vikunja.hostname} ${infra.vikunja.fqdn}.";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd. network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.vikunja.ip}/32";}];

  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    "authelia-vikunja" = {
      file = ../../modules/resources/authelia-vikunja.age;
      owner = "root"; # XXX
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.vikunja.fqdn}" = {
      listenAddresses = [infra.vikunja.ip];
      extraConfig = ''import intraproxy ${toString infra.vikunja.localbind.port.http}'';
    };
    vikunja = {
      enable = true;
      address = infra.localhost.ip;
      port = infra.vikunja.localbind.port.http;
      frontendScheme = "https";
      frontendHostname = infra.vikunja.fqdn;
      settings = {
        auth = {
          local.enabled = true;
          openid = {
            enabled = true;
            providers.authelia = {
              name = "Authelia";
              authurl = infra.sso.url;
              clientid = infra.vikunja.app;
              clientsecret = "yLK274tKaRZ2Y58T_rPlaNHTcoGdqGIUgOFDMBCKckeHZnrJXNo9FJG5veIWTeh61.HQJVmG";
              # clientsecret.file = config.age.secrets.authelia-vikunkja.path;
            };
          };
        };
      };
    };
  };
}
