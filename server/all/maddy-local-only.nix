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
    extraHosts = "${infra.smtp.ip} ${infra.smtp.hostname} ${infra.smtp.fqdn}";
    firewall.allowedTCPPorts = [infra.port.smtp infra.port.imap];
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.maddy = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    maddy = {
      enable = true;
      hostname = infra.smtp.fqdn;
      primaryDomain = infra.smtp.domain;
      config = ''
        # smtp
        smtp tcp://${infra.smtp.ip}:${toString infra.port.smtp} {
          limits {
            all rate 20 1s
            all concurrency 10
          }
          destination ${infra.smtp.domain} {
            deliver_to &local_routing
          }
          debug on
        }
        # imap
        imap tcp://${infra.imap.ip}:${toString infra.port.imap} {
          auth &local_authdb
          insecure_auth yes
          storage &local_mailboxes
          debug on
          io_errors on
          io_debug on
        }
        # ldap user auth
        auth.ldap local_authdb {
          urls ${infra.ldap.uri}
          dn_template "cn={username},${infra.ldap.baseDN}"
          starttls off
          connect_timeout 10s
          debug on
        }
        # store backend
        storage.imapsql local_mailboxes {
          driver sqlite3
          dsn imapsql.db
          compression zstd 6
          debug on
        }
        # routing
        msgpipeline local_routing {
          modify {
            replace_rcpt &local_rewrites
          }
          destination_in &local_mailboxes {
            deliver_to &local_mailboxes
          }
          destination $(local_domains) {
            modify {
              replace_rcpt regexp ".*" "catchall@$(primary_domain)"
            }
            deliver_to &local_mailboxes
          }
          default_destination {
            reject 550 5.1.1 "User doesn't exist"
          }
        }
        # rewrite filter
        table.chain local_rewrites {
          optional_step regexp "(.+)\+(.+)@(.+)" "$1@$3"
          optional_step static {
            entry postmaster postmaster@$(primary_domain)
          }
          optional_step file /etc/maddy/aliases
        }
      '';
    };
  };
}
