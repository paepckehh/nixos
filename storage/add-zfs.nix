{lib, ...}: {
  ########
  # BOOT #
  ########
  boot.supportedFilesystems = ["zfs"];

  ############
  # SERVICES #
  ############
  services = {
    prometheus.exporters.zfs.enable = false;
    zfs = {
      autoScrub = {
        enable = false;
        interval = "monthly";
      };
      autoSnapshot = {
        enable = false;
        daily = 7;
        weekly = 4;
      };
    };
  };
}
