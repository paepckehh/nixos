# res.nix => caddy resources (portal images, certs, ...)
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
  networking.extraHosts = "${infra.res.ip} ${infra.res.hostname} ${infra.res.fqdn}.";

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups."caddy" = {};
    users = {
      "caddy" = {
        group = "caddy";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh ssoentication
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.res.fqdn}" = {
      listenAddresses = [infra.res.ip];
      extraConfig = ''
        import intra
        root * /var/lib/caddy/res
        file_server browse
      '';
    };
  };
}
