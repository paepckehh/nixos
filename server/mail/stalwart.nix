{pkgs, ...}: {
  # env
  environment.etc."stalwart/pw".text = "start";

  ##################
  #-=# SERVICES #=-#
  ##################
  services.stalwart-mail = {
    enable = true;
    package = pkgs.stalwart-mail;
    settings = {
      server = {
        hostname = "mx.dbt.corp";
        tls = {
          enable = false;
          implicit = true;
        };
        listener = {
          management = {
            bind = ["127.0.0.1:7125"];
            protocol = "http";
          };
        };
      };
      lookup.default = {
        hostname = "mx.dbt.corp";
        domain = "dbt.corp";
      };
      session.auth = {
        mechanisms = "[plain]";
        directory = "'in-memory'";
      };
      session.rcpt.directory = "'in-memory'";
      queue.strategy.route = "'local'";
      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:/etc/stalwart/pw}%";
      };
      # storage.directory = "ldap";
      directory = {
        # imap.lookup.domains = ["dbt.corp"];
        default = {
          type = "ldap";
          base-dn = "dc=dbt,dc=corp";
          timeout = "30s";
          url = "ldap://127.0.0.1:3890";
          cache.entries = 500;
          attributes = {
            class = "objectClass";
            email = "mail";
            groups = "member";
            name = "uid";
            secret = "userPassword";
            description."0" = "cn";
          };
          bind = {
            dn = "uid=bind,ou=people,dc=dbt,dc=corp";
            secret = "startstart";
            auth = {
              enable = true;
              search = true;
              method = "lookup";
              dn = "uid=?,ou=people,dc=dbt,dc=corp";
            };
            filter = {
              email = "(&(|(objectClass=person)(member=cn=mail,ou=groups,dc=dbt,dc=corp))(mail=?))";
              name = "(&(|(objectClass=person)(member=cn=mail,ou=groups,dc=dbt,dc=corp))(uid=?))";
            };
          };
          filter = {
            email = "(&(objectclass=person)(mail=?))";
            name = "(&(objectclass=person)(uid=?))";
          };
          tls = {
            enable = false;
            allow-invalid-certs = true;
          };
        };
      };
    };
  };
}
