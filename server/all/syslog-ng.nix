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
    extraHosts = "${infra.syslog.user.ip} ${infra.syslog.user.fqdn}\n${infra.syslog.admin.ip} ${infra.syslog.admin.fqdn}";
    firewall = {
      allowedTCPPorts = [infra.port.syslog];
      allowedUDPPorts = [infra.port.syslog];
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    network.networks = {
      "${infra.namespace.admin}".addresses = [{Address = "${infra.syslog.admin.ip}/32";}];
      "${infra.namespace.user}".addresses = [{Address = "${infra.syslog.user.ip}/32";}];
    };
    services = {
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
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/syslog-ng-rotate.sh restart";
        };
      };
      syslog-ng-shutdown = {
        description = "archive syslog-ng logfiles at system shutdown";
        after = ["final.target"];
        wantedBy = ["final.target"];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/syslog-ng-rotate.sh";
        };
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    etc."scripts/syslog-ng-rotate.sh".text = ''
      #!/bin/sh
      LOGDIR="/var/syslog-ng/"
      LOGARCHIVE="/nix/persist/logs";
      LOGFILES="console.txt console-err.txt console-crit.txt"
      cd $LOGDIR || exit 1
      /run/current-system/sw/bin/touch $LOGFILES
      /run/current-system/sw/bin/chmod 640 $LOGFILES
      /run/current-system/sw/bin/mkdir -p $LOGARCHIVE
      /run/current-system/sw/bin/systemctl stop syslog-ng.service
      for logfile in $LOGFILES; do
          mv -f $logfile $LOGARCHIVE/$(date +%Y%m%d%H%M%S)-$logfile
      done
      if [ "$1" = "restart" ]; then /run/current-system/sw/bin/systemctl start syslog-ng.service; fi
      /run/current-system/sw/bin/xz -9e $LOGARCHIVE/*.txt
      /run/current-system/sw/bin/chown -R 0:0 $LOGARCHIVE
      /run/current-system/sw/bin/chmod -R 700 $LOGARCHIVE
      /run/current-system/sw/bin/sync
      /run/current-system/sw/bin/sync
      /run/current-system/sw/bin/sync
    '';
    shellAliases = {
      "console" = ''sudo tail -n 1500 -f /var/syslog-ng/console.txt           |  bat -f -l syslog --paging never'';
      "console.err" = ''sudo tail -n 1500 -f /var/syslog-ng/console-err.txt   |  bat -f -l syslog --paging never'';
      "console.crit" = ''sudo tail -n 1500 -f /var/syslog-ng/console-crit.txt |  bat -f -l syslog --paging never'';
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    syslog-ng = {
      enable = true;
      extraConfig = ''
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
                );
        };
        filter f_err  { level(err..emerg); };
        filter f_crit { level(crit..emerg); };
        destination d_log { file("/var/syslog-ng/console.txt");  };
        destination d_log_err { file("/var/syslog-ng/console-err.txt");  };
        destination d_log_crit { file("/var/syslog-ng/console-crit.txt");  };
        log { source(s_local); source(s_net_tcp); source(s_net_udp); destination(d_log); };
        log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_err); destination(d_log_err); };
        log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_crit); destination(d_log_crit); };
      '';
    };
  };
}
