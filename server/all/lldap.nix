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
  networking = {
    extraHosts = "${infra.iam.ip} ${infra.iam.hostname} ${infra.iam.fqdn}.";
    firewall = {
      allowedTCPPorts = [infra.port.ldap];
      allowedUDPPorts = [infra.port.ldap];
    };
  };

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      lldap-admin = {
        file = ../../modules/resources/lldap-admin.age;
        owner = "lldap";
        group = "lldap";
      };
      lldap-seed = {
        file = ../../modules/resources/lldap-seed.age;
        owner = "lldap";
        group = "lldap";
      };
      lldap-jwt = {
        file = ../../modules/resources/lldap-jwt.age;
        owner = "lldap";
        group = "lldap";
      };
      lldap-key = {
        file = ../../modules/resources/lldap-key.age;
        owner = "lldap";
        group = "lldap";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.lldap = {};
    users = {
      lldap = {
        group = "lldap";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [lldap-cli sqlitebrowser];
    etc."ssl/ldaps.crt".text = lib.mkForce ''
      ### LDAPS PEM CERT GOES HERE ###
    '';
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.lldap = {
    after = ["sockets.target"];
    wants = ["sockets.target"];
    wantedBy = ["multi-user.target"];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    lldap = {
      enable = true;
      settings = {
        # db
        database_url = "sqlite://./users.db?mode=rwc";
        # http web gui
        http_host = infra.localhost.ip;
        http_port = infra.iam.localbind.port.http;
        http_url = infra.iam.url;
        # interface
        ldap_host = infra.ldap.ip;
        ldap_port = infra.port.ldap;
        # ldap
        ldap_base_dn = infra.ldap.base;
        # ldap secrets
        ldap_jwt_secret = config.age.secrets.lldap-jwt.path;
        ldap_key_seed = config.age.secrets.lldap-seed.path;
        # ldap admin
        ldap_user_dn = infra.admin.name;
        ldap_user_email = infra.admin.email;
        ldap_user_pass_file = config.age.secrets.lldap-admin.path;
        force_ldap_user_pass_reset = false; # true for enforced reset to default
        # ldap compatiblity (AD)
        ignored_user_attributes = ["sAMAccountName"];
        ignored_group_attributes = ["mail" "userPrincipalName"];
        # log
        verbose = true;
        # smtp
        smtp_options = {
          enable_password_reset = true;
          server = infra.smtp.admin.fqdn;
          port = infra.port.smtp;
          smtp_encryption = "NONE";
          from = infra.admin.email;
          reply_to = infra.admin.email;
        };
        # ldaps
        ldaps_options = {
          enabled = false;
          cert_file = "/etc/ssl/ldaps.crt";
          key_file = config.age.secrets.lldap-key.path;
        };
      };
    };
    caddy.virtualHosts."${infra.iam.fqdn}" = {
      listenAddresses = [infra.iam.ip];
      extraConfig = ''import intraproxy ${toString infra.iam.localbind.port.http}'';
    };
  };
}
