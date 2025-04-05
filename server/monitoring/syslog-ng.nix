{
  config,
  pkgs,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.shellAliases."console" = ''sudo tail -f /var/syslog-ng/console.txt |  bat --force-colorization --language syslog --paging never'';

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    syslog-ng = {
      enable = true;
      extraConfig = ''
        options {
            time-reap(30);
            mark-freq(10);
            keep-hostname(yes);
        };
        source s_local {
            system(); internal();
        };
        source s_network_rfc3164 {
                network(
                        ip("0.0.0.0")
                        ip-protocol(4)
                        transport(tcp)
                        port(514) 
                        listen-backlog(4096)
                        log-msg-size(65536) 
                        so-reuseport(1)
                );
        };
        destination d_logs {
            file(
                "/var/syslog-ng/console.txt"
                owner("root")
                group("root")
                perm(0770)
                );
            };
        log {
            source(s_local); source(s_network_rfc3164); destination(d_logs);
        };'';
      extraModulePaths = [];
      package = pkgs.syslogng;
    };
  };
  ##############
  # NETWORKING #
  ##############
  networking = {
    firewall = {
      allowedTCPPorts = [
        514 # RFC3164
        # 601   # RFC5424
        # 6514  # RFC5424 TLS Port
      ];
      allowedUDPPorts = [
        # 514  # RFC3164
      ];
    };
  };
}
