{lib, ...}: {
  ###############
  #-=# DISKO #=-#
  ###############
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sdc";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            swap = {
              size = "8G";
              content = {
                type = "swap";
                randomEncryption = true;
                priority = 50;
              };
            };
            nix = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
                mountOptions = ["noatime" "nodiratime" "discard" "commit=30" "nobarrier" "data=writeback" "journal_async_commit"];
              };
            };
          };
        };
      };
    };
    nodev = {
      "tmpfs" = {
        mountpoint = "/";
        fsType = "tmpfs";
        mountOptions = [
          "size=80%"
        ];
      };
    };
  };
}
