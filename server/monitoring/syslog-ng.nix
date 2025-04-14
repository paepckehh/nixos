{
  config,
  pkgs,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases."console" = ''sudo tail -n 1500 -f /var/syslog-ng/console.txt |  bat --force-colorization --language syslog --paging never'';
    shellAliases."console.all" = ''sudo tail -n 1500 -f /var/syslog-ng/console-all.txt |  bat --force-colorization --language syslog --paging never'';
    shellAliases."console.err" = ''sudo tail -n 1500 -f /var/syslog-ng/console-err.txt |  bat --force-colorization --language syslog --paging never'';
    shellAliases."console.crit" = ''sudo tail -n 1500 -f /var/syslog-ng/console-crit.txt |  bat --force-colorization --language syslog --paging never'';
  };

  ##############
  # NETWORKING #
  ##############
  networking.firewall.allowedTCPPorts = [514];

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
            dir-perm(0755);
            group("wheel");
            owner("root");
            perm(0750);
            sync(0);
        };
        source s_local {
            system();
            internal();
        };
        source s_network_rfc3164_tcp {
                network(
                        ip("0.0.0.0")
                        ip-protocol(4)
                        transport("tcp")
                        port(514)
                        listen-backlog(4096)
                        log-msg-size(65536)
                        so-reuseport(1)
                );
        };
        filter f_crond { not program(crond); };
        filter f_err  { level(err..emerg); };
        filter f_crit { level(crit..emerg); };
        destination d_log { file("/var/syslog-ng/console.txt");  };
        destination d_log_all { file("/var/syslog-ng/console-all.txt");  };
        destination d_log_err { file("/var/syslog-ng/console-err.txt");  };
        destination d_log_crit { file("/var/syslog-ng/console-crit.txt");  };
        log { source(s_local); source(s_network_rfc3164_tcp); destination(d_log_all); };
        log { source(s_local); source(s_network_rfc3164_tcp); filter(f_crond); destination(d_log); };
        log { source(s_local); source(s_network_rfc3164_tcp); filter(f_crond); filter(f_err); destination(d_log_err); };
        log { source(s_local); source(s_network_rfc3164_tcp); filter(f_crond); filter(f_crit); destination(d_log_crit); };
      '';
    };
  };
}
