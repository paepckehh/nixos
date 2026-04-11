{
  ################
  #-=# IMPORT #=-#
  ################
  imports = [
    ./git-mirror-scripts.nix
  ];

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    services = {
      "git-mirror-cache" = {
        description = "git-mirror-cache";
        serviceConfig = {
          User = "root";
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/git-mirror-cache.sh";
        };
      };
      "git-mirror-fetch" = {
        description = "git-mirror-fetch";
        serviceConfig = {
          User = "root";
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/git-mirror-fetch.sh";
        };
      };
      "git-mirror-gc" = {
        description = "git-mirror-gc";
        serviceConfig = {
          User = "root";
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/git-mirror-gc.sh";
        };
      };
      "git-mirror-gc-full" = {
        description = "git-mirror-gc-full";
        serviceConfig = {
          User = "root";
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/git-mirror-gc-full.sh";
        };
      };
      "git-mirror-gc-max" = {
        description = "git-mirror-gc-max";
        serviceConfig = {
          User = "root";
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/sh /etc/scripts/git-mirror-gc-max.sh";
        };
      };
    };
    timers = {
      "git-mirror-cache-timer" = {
        description = "git-mirror-cache-timer";
        wantedBy = ["timers.target"];
        timerConfig = {
          Unit = "git-mirror-cache.service";
          OnCalendar = "hourly";
          Persistent = false;
        };
      };
      "git-mirror-fetch-timer" = {
        description = "git-mirror-fetch-timer";
        wantedBy = ["timers.target"];
        timerConfig = {
          Unit = "git-mirror-fetch.service";
          OnCalendar = "*-*-* 00:40:00";
          Persistent = false;
        };
      };
      "git-mirror-fetch-timer2" = {
        description = "git-mirror-fetch-timer2";
        wantedBy = ["timers.target"];
        timerConfig = {
          Unit = "git-mirror-fetch.service";
          OnCalendar = "*-*-* 04:40:00";
          Persistent = false;
        };
      };
      "git-mirror-gc-timer" = {
        description = "git-mirror-gc-timer";
        wantedBy = ["timers.target"];
        timerConfig = {
          Unit = "git-mirror-gc.service";
          OnCalendar = "*-*-* 04:50:00";
          Persistent = false;
        };
      };
      "git-mirror-gc-full-timer" = {
        description = "git-mirror-gc-full-timer";
        wantedBy = ["timers.target"];
        timerConfig = {
          Unit = "git-mirror-gc-full.service";
          OnCalendar = "*-*-05 23:00:00";
          Persistent = false;
        };
      };
      "git-mirror-gc-max-timer" = {
        description = "git-mirror-gc-max-timer";
        wantedBy = ["timers.target"];
        timerConfig = {
          Unit = "git-mirror-gc-max.service";
          OnCalendar = "*-01-20 23:00:00";
          Persistent = false;
        };
      };
    };
  };
}
