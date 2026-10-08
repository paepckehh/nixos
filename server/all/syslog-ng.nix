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
    extraHosts = ''
      ${infra.syslog.admin.ip} ${infra.syslog.admin.fqdn}
      ${infra.syslog.user.ip} ${infra.syslog.user.fqdn}
    '';
    firewall = {
      allowedTCPPorts = [infra.port.syslog];
      allowedUDPPorts = [infra.port.syslog];
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services = {
    syslog-ng = {
      after = ["sockets.target"];
      wants = ["sockets.target"];
      wantedBy = ["multi-user.target"];
    };
    syslog-ng-rotate = {
      description = "rotate syslog-ng logfiles at midnight";
      startAt = ["*-*-* 00:00:00"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/syslog-ng-rotate.sh";
      };
    };
    syslog-ng-shutdown = {
      description = "archive syslog-ng logfiles at system shutdown";
      after = ["final.target"];
      wantedBy = ["final.target"];
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/syslog-ng-rotate.sh down";
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    journald.storage = "volatile";
    syslog-ng = {
      enable = true;
      extraConfig = lib.mkForce ''
        options {
            create-dirs(yes);
            chain-hostnames(yes);
            dir-group("wheel");
            dir-owner("root");
            dir-perm(0750);
            group("wheel");
            owner("root");
            perm(0640);
            sync(0);
            stats_freq(0);
            flush_lines(100);
            use_dns(no);
            use_fqdn(no);
        };
        source s_local {
            system();
            internal();
        };
        source s_net_tcp {
                network(
                        ip("0.0.0.0")
                        ip-protocol(4)
                        transport("tcp")
                        port(${toString infra.port.syslog})
                        listen-backlog(4096)
                        log-msg-size(65536)
                        so-reuseport(1)
                        max-connections(2048)
                );
        };
        source s_net_udp {
                network(
                        ip("0.0.0.0")
                        ip-protocol(4)
                        transport("udp")
                        port(${toString infra.port.syslog})
                        listen-backlog(4096)
                        log-msg-size(65536)
                        so-reuseport(1)
                        max-connections(2048)
                );
        };
        filter f_err  { level(err..emerg); };
        filter f_crit { level(crit..emerg); };
        filter f_hostwatch { program("hostwatch"); };
        filter f_newstation { program("hostwatch"); match("new station host", value("MESSAGE")); };
        filter f_unipot { program("caddy"); match("unifi.adm.corp", value("MESSAGE")); and not match("enabling automatic", value("MESSAGE"))};
        destination d_log { file("/var/syslog-ng/console.txt"); };
        destination d_log_err { file("/var/syslog-ng/console-err.txt"); };
        destination d_log_crit { file("/var/syslog-ng/console-crit.txt"); };
        destination d_log_hostwatch { file("/var/syslog-ng/console-hostwatch.txt"); };
        destination d_log_newstation { file("/var/syslog-ng/console-newstation.txt"); };
        destination d_log_uni { file("/var/syslog-ng/console-unifi-honypot.txt"); };
        destination d_mail_dev { smtp(host("10.20.6.102") port(25) from("it@debitor.de" "it@debitor.de") to("it@debitor.de" "it@debitor.de") subject("[ALERT] DEBITOR SYSLOG") body("$\{MSG\}\n")); };
        log { source(s_local); source(s_net_tcp); source(s_net_udp); destination(d_log); };
        log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_err); destination(d_log_err); };
        log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_crit); destination(d_log_crit); };
        log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_hostwatch); destination(d_log_hostwatch); };
        log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_newstation); destination(d_log_newstation); };
        log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_newstation); destination(d_log_newstation); };
        log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_unipot); destination(d_log_uni); };
        log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_unipot); destination(d_mail_dev); };
        log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_newstation); destination(d_mail_dev); };
      '';
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    etc."scripts/syslog-ng-rotate.sh".text = ''
      #!/bin/sh
      LOGDIR="/var/syslog-ng"
      ARCHIV="/nix/persist/archiv/logs";
      FILES="console.txt console-err.txt console-crit.txt console-hostwatch.txt console-newstation.txt"
      EXEC="/run/current-system/sw/bin"
      DTS="$($EXEC/date +%Y-%m-%d-%H%M%S)"
      SNAP="$LOGDIR/.$($EXEC/uuidgen)"
      $EXEC/mkdir -p $SNAP $ARCHIV
      $EXEC/chown -R 0:0 $SNAP $ARCHIV
      $EXEC/chmod -R 700 $SNAP $ARCHIV
      for file in $FILES; do
          $EXEC/touch $LOGDIR/$file
          $EXEC/link  $LOGDIR/$file $SNAP/$file
      done
      $EXEC/systemctl stop syslog-ng.service
      for file in $FILES; do
          $EXEC/unlink $LOGDIR/$file
      done
      if [ "$1" != "down" ]; then $EXEC/systemctl start syslog-ng.service; fi
      for file in $FILES; do
          $EXEC/cat $SNAP/$file | $EXEC/xz -9e --compress --stdout > $ARCHIV/$DTS.$file.xz
          $EXEC/unlink $SNAP/$file
          $EXEC/sync
      done
      $EXEC/rm -rf $SNAP
      $EXEC/chown -R 0:0 $ARCHIV
      $EXEC/chmod -R 700 $ARCHIV
      $EXEC/ln -sf /nix/persist/archiv/logs /var/syslog-ng/ || true
    '';
    shellAliases = {
      "console" = ''sudo tail --lines 1000 -f /var/syslog-ng/console.txt | bat -f -l syslog --paging never'';
      "console.err" = ''sudo tail --lines 1000 -f /var/syslog-ng/console-err.txt | bat -f -l syslog --paging never'';
      "console.crit" = ''sudo tail --lines 1000 -f /var/syslog-ng/console-crit.txt | bat -f -l syslog --paging never'';
      "console.hostwatch" = ''sudo tail --lines 1000 -f /var/syslog-ng/console-hostwatch.txt | bat -f -l syslog --paging never'';
      "console.new-station" = ''sudo tail --lines 1000 -f /var/syslog-ng/console-newstation.txt | bat -f -l syslog --paging never'';
    };
  };
}
# destination d_mail_uni { smtp(host("10.20.6.102") port(25) from("it@debitor.de" "it@debitor.de") to("it@debitor.de" "it@debitor.de") subject("[ALERT] NEW UNIFI Honeypot Tripwire-Trigger") body("$\{MSG\}\n")); };

