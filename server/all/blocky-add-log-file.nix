{
  pkgs,
  lib,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.shellAliases."log.dns.blocky" = ''sudo tail -n 1500 -f /var/lib/blocky/$(date +%Y-%m-%d_ALL.log) |  bat --force-colorization --language syslog --paging never'';

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      settings = {
        queryLog = {
          type = "csv"; # needs nixos upstream bugfix PR388962 (merged to master now, no backport)
          target = "/var/lib/blocky";
          logRetentionDays = 180;
          creationAttempts = 15;
          creationCooldown = "15s";
          flushInterval = "15s";
        };
      };
    };
  };
}
