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
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    journald.storage = lib.mkForce "volatile";
    syslog-ng = {
      enable = true;
      extraConfig = ''
        source s_local { system(); internal(); };
        destination d_syslog_tcp { syslog("${infra.syslog.ip}" ip-protocol(4) transport(tcp) port(${infra.port.syslog})); };
        log{ source(s_local); destination(d_syslog_tcp); };
      '';
    };
  };
}
