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
  networking.extraHosts = "${infra.coturn.ip} ${infra.coturn.hostname} ${infra.coturn.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.coturn.ip}/32";}];

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      coturn = {
        file = ../../modules/resources/coturn.age;
        owner = "coturn";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.coturn = {};
    users = {
      coturn = {
        group = "coturn";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy = {
      virtualHosts."${infra.coturn.fqdn}" = {
        listenAddresses = [infra.coturn.ip];
        extraConfig = ''import intraproxy ${toString infra.coturn.localbind.port.http}'';
      };
      coturn = {
        enable = true;
        static-auth-secret-file = config.age.secrets.coturn.path;
      };
    };
  };
}
