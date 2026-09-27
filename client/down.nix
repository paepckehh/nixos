{
  lib,
  pkgs,
  ...
}: {
  ################
  #-= SYSTEMD #=-#
  ################
  systemd = {
    services = {
      poweroff = {
        description = "Poweroff Service";
        startAt = "*-*-* 20:00:00";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.systemd}/bin/poweroff --force";
        };
      };
    };
  };
}
