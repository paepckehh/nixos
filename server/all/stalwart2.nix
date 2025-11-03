{pkgs, ...}: {
  # Needs paepcke.corp dns infra include
  ##############
  # NETWORKING #
  ##############
  networking.firewall.allowedTCPPorts = [80 443]; # caddy reverse proxy

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.etc = {
    "stalwart/mail-pw1".text = "start";
    "stalwart/mail-pw2".text = "start";
    "stalwart/admin-pw".text = "start";
    # "stalwart/acme-secret".text = "start";
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services.stalwart-mail = {
    enable = true;
    package = pkgs.stalwart-mail;
    openFirewall = true;
    settings = {
      server = {
        hostname = "mx1.paepcke.corp";
        tls = {
          enable = true;
          implicit = true;
        };
        listener = {
          smtp = {
            protocol = "smtp";
            bind = "[::]:25";
          };
          submissions = {
            bind = "[::]:465";
            protocol = "smtp";
          };
          imaps = {
            bind = "[::]:993";
            protocol = "imap";
          };
          jmap = {
            bind = "[::]:8080";
            url = "https://mail.paepcke.corp";
            protocol = "jmap";
          };
          management = {
            bind = ["127.0.0.1:8080"];
            protocol = "http";
          };
        };
      };
      lookup.default = {
        hostname = "mx1.paepcke.corp";
        domain = "paepcke.corp";
      };
      # acme."letsencrypt" = {
      #  directory = "https://acme-v02.api.letsencrypt.org/directory";
      #  challenge = "dns-01";
      #  contact = "user1@example.org";
      #  domains = ["example.org" "mx1.example.org"];
      #  provider = "cloudflare";
      #  secret = "%{file:/etc/stalwart/acme-secret}%";
      # };
      session.auth = {
        mechanisms = "[plain]";
        directory = "'in-memory'";
      };
      storage.directory = "in-memory";
      session.rcpt.directory = "'in-memory'";
      queue.outbound.next-hop = "'local'";
      directory."imap".lookup.domains = ["paepcke.corp"];
      directory."in-memory" = {
        type = "memory";
        principals = [
          {
            class = "individual";
            name = "PAEPCKE, Michael";
            secret = "%{file:/etc/stalwart/mail-pw1}%";
            email = ["mp@paepcke.corp"];
          }
          {
            class = "individual";
            name = "postmaster";
            secret = "%{file:/etc/stalwart/mail-pw1}%";
            email = ["postmaster@paepcke.corp"];
          }
        ];
      };
      authentication.fallback-admin = {
        user = "admin";
        secret = "%{file:/etc/stalwart/admin-pw}%";
      };
    };
    caddy = {
      enable = true;
      virtualHosts = {
        "webadmin.paepcke.corp" = {
          extraConfig = ''
            reverse_proxy http://127.0.0.1:8080
          '';
          serverAliases = [
            "mta-sts.paepcke.corp"
            "autoconfig.paepcke.corp"
            "autodiscover.paepcke.corp"
            "mail.paepcke.corp"
          ];
        };
      };
    };
  };
}
