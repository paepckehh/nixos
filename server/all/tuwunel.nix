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

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      tuwunel = {
        file = ../../modules/resources/matrix.age;
        owner = "tuwunel";
        group = "tuwunel";
      };
      tuwunel-ldap-bind = {
        file = ../../modules/resources/bind.age;
        owner = "tuwunel";
        group = "tuwunel";
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
          ldap = {
            enable = infra.matrix.ldap;
            uri = infra.ldap.uri;
            bind_dn = infra.ldap.bind.dn;
            bind_password_file = config.age.secrets.tuwunel-ldap-bind.path;
            filter = "(objectClass=*)";
            uid_attribute = "uid";
            mail_attribute = "mail";
            name_attribute = "givenName";
          };
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
