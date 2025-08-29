{
  pkgs,
  config,
  lib,
  ...
}: let
  infra = {
    lan = {
      services = {
        ldap = {
          ip = "10.20.0.126";
          hostname = "ldap";
          domain = "adm.corp";
          namespace = "00-${infra.lan.services.ldap.domain}";
          network = "10.20.0.0/24";
          ports.tcp = 3890;
          base-dn = "dc=dbt,dc=corp";
          admin = {
            user = "admin";
            email = "it@debitor.de";
          };
        };
        ldap-gui = {
          ip = "10.20.6.126";
          hostname = "iam";
          domain = "dbt.corp";
          namespace = "06-${infra.lan.services.ldap-gui.domain}";
          network = "10.20.6.0/23";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            port = 7126;
          };
        };
      };
    };
  };
in {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../../packages/agenix.nix
  ];

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks = {
    ${infra.lan.services.ldap.namespace}.addresses = [{Address = "${infra.lan.services.ldap.ip}/32";}];
    ${infra.lan.services.ldap-gui.namespace}.addresses = [{Address = "${infra.lan.services.ldap-gui.ip}/32";}];
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.ldap.ip} ${infra.lan.services.ldap.hostname} ${infra.lan.services.ldap.hostname}.${infra.lan.services.ldap.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.ldap.ports.tcp infra.lan.services.ldap-gui.ports.tcp];
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
    systemPackages = with pkgs; [lldap-cli sqlitebrowser jxplorer];
    etc."ssl/ldaps.crt".text = lib.mkForce ''
      ### LDAPS PEM CERT GOES HERE ###
    '';
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
        http_host = "${infra.lan.services.ldap-gui.localbind.ip}";
        http_port = infra.lan.services.ldap-gui.localbind.port;
        http_url = "https://${infra.lan.services.ldap-gui.hostname}.${toString infra.lan.services.ldap-gui.domain}";
        # ldap
        ldap_host = "${infra.lan.services.ldap.ip}";
        ldap_port = infra.lan.services.ldap.ports.tcp;
        ldap_base_dn = "${infra.lan.services.ldap.base-dn}";
        # ldap secrets
        ldap_jwt_secret = config.age.secrets.lldap-jwt.path;
        ldap_key_seed = config.age.secrets.lldap-seed.path;
        # ldap admin
        ldap_user_dn = "${infra.lan.services.ldap.admin.user}";
        ldap_user_email = "${infra.lan.services.ldap.admin.email}";
        # enable only for adminitrative admin password reset or init
        force_ldap_user_pass_reset = false;
        silenceForceUserPassResetWarning = true;
        ldap_user_pass_file = config.age.secrets.lldap-admin.path;
        # compatiblity (AD)
        ignored_user_attributes = ["sAMAccountName"];
        ignored_group_attributes = ["mail" "userPrincipalName"];
        # log
        verbose = true;
        # smtp
        smtp_options = {
          enable_password_reset = true;
          server = "smtp.${infra.lan.services.ldap.domain}";
          port = 25;
          smtp_encryption = "NONE";
          from = "${infra.lan.services.ldap.admin.email}";
          reply_to = "${infra.lan.services.ldap.admin.email}";
        };
        # ldaps
        ldaps_options = {
          enabled = false;
          cert_file = "/etc/ssl/ldaps.crt";
          key_file = config.age.secrets.lldap-key.path;
        };
      };
    };
  };
}
