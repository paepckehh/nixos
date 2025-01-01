{
  config,
  disko,
  ...
}: {
  ###############
  #-=# DISKO #=-#
  ###############
  disko = {
    devices = {
      disk = {
        main = {
          device = "/dev/$DISKO_DEVICE_MAIN";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                size = "1G";
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
                  priority = 100;
                  extraArgs = ["--label swap"];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  extraArgs = ["--label root"];
                };
              };
            };
          };
        };
      };
    };
  };

