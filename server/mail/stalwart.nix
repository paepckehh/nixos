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
      storage.directory = "in-memory";
      session.rcpt.directory = "'in-memory'";
      # queue.outbound.next-hop = "'local'";
      queue.strategy.route = "'local'";
      directory."imap".lookup.domains = ["dbt.corp"];
      directory."in-memory" = {
        type = "memory";
        principals = [
          {
            class = "individual";
            name = "postmaster";
            secret = "%{file:/etc/stalwart/pw}%";
            email = ["postmaster@example.org"];
          }
        ];
      };
      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:/etc/stalwart/pw}%";
      };
    };
  };
}
