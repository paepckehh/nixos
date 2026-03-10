{
  ################
  #-= SYSTEMD #=-#
  ################
  systemd = {
    user.services = {
      poweroff = {
        description = "Poweroff Service";
        startAt = ["*-*-* 20:00:00"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "/run/current-system/sw/bin/poweroff";
        };
      };
    };
  };
}
