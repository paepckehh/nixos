{...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../../modules/agenix.nix
  ];

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      lldapadmin = {
        file = ../../modules/resources/lldapadmin.age;
        owner = "lldap";
        group = "lldap";
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
        http_port = "9090";
        ldap_base_dn = "dc=debitor,dc=corp";
        ldap_user_dn = "admin";
        ldap_user_email = "it@debitor.de";
        ldap_user_pass_file = config.age.secrets.lladpadmin.path;
        ldap_host = "127.0.0.1";
        ldap_port = "3890";
      };
    };
  };
}
