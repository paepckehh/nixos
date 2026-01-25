# matrix messenger
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
  networking.extraHosts = "${infra.matrix.ip} ${infra.matrix.hostname} ${infra.matrix.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.matrix.ip}/32";}];

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      tuwunel = {
        file = ../../modules/resources/matrix.age;
        owner = "tuwunel";
      };
      coturn-matrix = {
        file = ../../modules/resources/coturn-matrix.age;
        owner = "tuwunel";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.tuwunel = {};
    users = {
      tuwunel = {
        group = "tuwunel";
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
    matrix-tuwunel = {
      enable = true;
      settings = {
        global = {
          address = [infra.localhost.ip];
          port = [infra.matrix.localbind.port.http];
          server_name = infra.matrix.fqdn;
          allow_encryption = false;
          allow_federation = false;
          allow_registration = infra.matrix.self-register.enable;
          registration_token = infra.matrix.self-register.password;
          rocksdb_compression_algo = "zstd";
          turn_allow_guests = true;
          turn_secret_file = config.age.secrets.coturn-matrix.path;
          turn_uris = [infra.coturn.fqdn];
        };
      };
    };
    caddy = {
      virtualHosts."${infra.matrix.fqdn}" = {
        listenAddresses = [infra.matrix.ip];
        extraConfig = ''import intraproxy ${toString infra.matrix.localbind.port.http}'';
      };
    };
  };
}
