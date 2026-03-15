{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../siteconfig/config.nix).infra;
in {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    journald.storage = lib.mkForce "volatile";
    syslog-ng = {
      enable = true;
      extraConfig = ''
        options { flush_lines(100); use_dns(no); use_fqdn(no); sync(0); stats_freq(0); };
        source s_local { system(); internal(); };
        destination d_syslog_udp { syslog("${infra.syslog.user.ip}" ip-protocol(4) transport(udp) port(${toString infra.port.syslog})); };
        log{ source(s_local); destination(d_syslog_udp); };
      '';
    };
  };
}
