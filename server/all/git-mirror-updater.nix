{
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    services = {
      "git-mirror-fetch" = {
        description = "git-mirror-fetch";
        timerConfig = {
          OnCalendar = "*-*-* 01:40:00";
          OnCalendar = "*-*-* 03:40:00";
          Persistent = false;
        };
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/git-mirror-fetch.sh";
        };
      };
      "git-mirror-gc" = {
        description = "git-mirror-gc";
        timerConfig = {
          OnCalendar = "*-*-* 02:40:00";
          Persistent = false;
        };
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/git-mirror-gc.sh";
        };
      };
      "git-mirror-gc-full" = {
        description = "git-mirror-gc-full";
        timerConfig = {
          OnCalendar = "Sun 22:00:00";
          Persistent = false;
        };
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/git-mirror-gc-full.sh";
        };
      };
    };
  };
}
