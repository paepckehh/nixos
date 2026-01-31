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
  networking.extraHosts = "${infra.onlyoffice.ip} ${infra.onlyoffice.hostname} ${infra.onlyoffice.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.onlyoffice.ip}/32";}];

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      onlyoffice-jwt = {
        file = ../../modules/resources/onlyoffice-jwt.age;
        owner = "onlyoffice";
      };
      onlyoffice-nonce = {
        # set $secure_link_secret "changeme";
        file = ../../modules/resources/onlyoffice-nonce.age;
        owner = "onlyoffice";
        group = "onlyoffice";
        mode = "440"; # nginx group access
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups."${infra.onlyoffice.name}" = {};
    users = {
      "${infra.onlyoffice.name}" = {
        group = "${infra.onlyoffice.name}";
        isSystemUser = true;
        hashedPassword = null;
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.onlyoffice.fqdn}" = {
      listenAddresses = [infra.onlyoffice.ip];
      extraConfig = ''import intraproxy ${toString infra.onlyoffice.localbind.port.http}'';
    };
    epmd.listenStream = "0.0.0.0:4369";
    onlyoffice = {
      enable = true;
      # hostname = infra.localhost.ip;
      port = infra.onlyoffice.localbind.port.http;
      jwtSecretFile = config.age.secrets.onlyoffice-jwt.path;
      securityNonceFile = config.age.secrets.onlyoffice-nonce.path;
    };
  };
}
