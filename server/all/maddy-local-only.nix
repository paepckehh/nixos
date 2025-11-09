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

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.maddy = {};
    users = {
      maddy = {
        group = "maddy";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
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
      localDomains = [infra.smtp.domain];
      config = ''
        # listen smtp
        smtp tcp://${infra.smtp.ip}:${toString infra.port.smtp} {
          limits {
            all rate 20 1s
            all concurrency 10
          }
          destination ${infra.smtp.domain} {
            deliver_to &local_routing
          }
          default_destination {
            reject 550 5.1.1 "User or Domain doesn't exist"
          }
          debug on
        }
        # listen imap
        imap tcp://${infra.imap.ip}:${toString infra.port.imap} {
          auth &local_authdb
          insecure_auth yes
          storage &local_mailboxes
          debug on
          io_errors on
          io_debug on
        }
        # backend ldap user auth
        auth.ldap local_authdb {
          urls ${infra.ldap.uri}
          dn_template "cn={username},${infra.ldap.baseDN}"
          starttls off
          connect_timeout 10s
          debug on
        }
        # backend storage
        storage.imapsql local_mailboxes {
          driver sqlite3
          dsn imapsql.db
          compression zstd 6
          debug on
        }
        # message routing
        msgpipeline local_routing {
          modify {
            replace_rcpt &local_rewrites
          }
          destination_in &local_mailboxes {
            deliver_to &local_mailboxes
          }
          # catchall => it@
          destination ${infra.smtp.domain} {
            modify {
              replace_rcpt regexp ".*" "it@${infra.smtp.domain}"
            }
            deliver_to &local_mailboxes
          }
          default_destination {
            reject 550 5.1.1 "User doesn't exist"
          }
        }
        # message rewrite filter
        table.chain local_rewrites {
          optional_step regexp "(.+)\+(.+)@(.+)" "$1@$3"
          optional_step static {
            entry postmaster it@${infra.smtp.domain}
          }
          optional_step file /etc/maddy/aliases
        }
      '';
    };
  };
}
