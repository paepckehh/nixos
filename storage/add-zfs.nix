{lib, ...}: {
  ########
  # BOOT #
  ########
  boot.zfs.enabled = true;

  ############
  # SERVICES #
  ############
  services = {
    prometheus.exporters.zfs.enable = false;
    zfs = {
      autoScrub = {
        enabled = false;
        interval = "monthly";
      };
      autoSnapshot = {
        enabled = false;
        daily = 7;
        weekly = 4;
      };
    };
  };
}
