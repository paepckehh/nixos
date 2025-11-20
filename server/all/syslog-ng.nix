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

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.shellAliases = {
    "console" = ''sudo tail -n 1500 -f /var/syslog-ng/console.txt           |  bat -f -l syslog --paging never'';
    "console.all" = ''sudo tail -n 1500 -f /var/syslog-ng/console-all.txt   |  bat -f -l syslog --paging never'';
    "console.err" = ''sudo tail -n 1500 -f /var/syslog-ng/console-err.txt   |  bat -f -l syslog --paging never'';
    "console.crit" = ''sudo tail -n 1500 -f /var/syslog-ng/console-crit.txt |  bat -f -l syslog --paging never'';
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  systemd.services.syslog-ng = {
    after = ["sockets.target"];
    wants = ["sockets.target"];
    wantedBy = ["multi-user.target"];
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

        d_smtp_admin{
                 smtp(
                         host("${infra.smtp.admin.fqdn}")
                         port(${toString infra.port.smtp})
                         from("syslog-ng alert service" "${infra.admin.email}")
                         to("ADMIN ${infra.admin.email}" "${infra.admin.email}")
                         subject("[ALERT] Important log message of XXX-LEVEL condition received from XXX-HOST-PROGRAM!")
                         body("Hi!\nThe syslog-ng alerting service detected the following important log message:\n XXX-MSG \n-- \nsyslog-ng\n")
                );
         };
         filter f_err  { level(err..emerg); };
         filter f_crit { level(crit..emerg); };
         destination d_log { file("/var/syslog-ng/console.txt");  };
         destination d_log_all { file("/var/syslog-ng/console-all.txt");  };
         destination d_log_err { file("/var/syslog-ng/console-err.txt");  };
         destination d_log_crit { file("/var/syslog-ng/console-crit.txt");  };
         log { source(s_local); source(s_net_tcp); source(s_net_udp); destination(d_log_all); };
         log { source(s_local); source(s_net_tcp); source(s_net_udp); destination(d_log); };
         log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_err); destination(d_log_err); };
         log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_crit); destination(d_log_crit); };
         log { source(s_local); source(s_net_tcp); source(s_net_udp); filter(f_crit); destination(d_smtp_admin); };'';
    };
  };
}
