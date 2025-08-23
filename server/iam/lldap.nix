{
  config,
  pkgs,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../../packages/agenix.nix
  ];

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
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      lldap = {
        group = "lldap";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
    groups.lldap = {};
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [lldap-cli sqlitebrowser];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    lldap = {
      enable = true;
      settings = {
        database_url = "sqlite://./users.db?mode=rwc";
        http_url = "http://localhost:9090/";
        http_host = "127.0.0.1";
        http_port = 9090;
        ldap_base_dn = "dc=debitor,dc=corp";
        ldap_user_dn = "admin";
        ldap_user_email = "it@debitor.de";
        ldap_user_pass_file = config.age.secrets.lldap-admin.path;
        ldap_host = "127.0.0.1";
        ldap_port = 3890;
      };
    };
  };
}
