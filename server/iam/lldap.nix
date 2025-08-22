{config, ...}: {
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
        owner = "root";
        group = "root";
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    lldap = {
      enable = true;
      environment = {
        # LLDAP_JWT_SECRET_FILE = "/run/lldap/jwt_secret";
        # LLDAP_LDAP_USER_PASS_FILE = "/run/lldap/user_password";
      };
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
