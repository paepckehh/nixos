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
      hostname = infra.smtp.domain;
      primaryDomain = infra.smtp.domain;
      config = ''
        storage.imapsql local_mailboxes {
          driver sqlite3
          dsn imapsql.db
        }
        smtp tcp://${infra.smtp.ip}:${toString infra.port.smtp} {
          limits {
            all rate 20 1s
            all concurrency 10
          }
          destination ${infra.smtp.domain} {
             deliver_to &local_mailboxes
          }
          reject 551 "Target Domain not local, go away!"
        }
        imap tcp://${infra.imap.ip}:${toString infra.port.imap} {
          auth &local_authdb
          storage &local_mailboxes
        }
        auth.ldap local_authdb {
          urls ${infra.ldap.uri}
          dn_template "cn={username},${infra.ldap.baseDN}"
          starttls off
          debug on
          connect_timeout 1m
        }
      '';
    };
  };
}
