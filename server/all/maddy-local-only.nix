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
        table.chain local_rewrites {
          optional_step regexp "(.+)\+(.+)@(.+)" "$1@$3"
          optional_step file /etc/maddy/aliases
        }
        storage.imapsql local_mailboxes {
          driver sqlite3
          dsn imapsql.db
          compression zstd 6
          debug on
        }
        smtp tcp://${infra.smtp.ip}:${toString infra.port.smtp} {
          limits {
            all rate 20 1s
            all concurrency 10
          }
          destination ${infra.smtp.domain} {
            modify {
               replace_rcpt &local_rewrites
            }
            deliver_to &local_mailboxes
          }
          default_destination {
           reject 550 5.1.1 "User doesn't exist in local target domain, or wrong target domain."
          }
          debug on
        }
        imap tcp://${infra.imap.ip}:${toString infra.port.imap} {
          auth &local_authdb
          insecure_auth yes
          storage &local_mailboxes
          debug on
          io_errors on
          io_debug on
        }
        auth.ldap local_authdb {
          urls ${infra.ldap.uri}
          dn_template "cn={username},${infra.ldap.baseDN}"
          starttls off
          connect_timeout 10s
          debug on
        }
      '';
    };
  };
}
