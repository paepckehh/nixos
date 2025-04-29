{lib, ...}: {
  ###############
  #-=# DISKO #=-#
  ###############
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sdb"; # autoinstaller dummy target
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
                initrdUnlock = true;
                name = "nix";
                type = "luks";
                passwordFile = "/tmp/luks";
                settings.allowDiscards = true;
                extraFormatArgs = [
                  "--type luks2"
                  "--cipher aes-xts-plain64"
                  "--pbkdf argon2id"
                  "--iter-time 5000"
                ];
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/nix";
                  # mountOptions = ["noatime" "nodiratime" "discard" "commit=30" "nobarrier" "data=writeback" "journal_async_commit"];
                  mountOptions = ["noatime" "nodiratime" "discard"];
                };
              };
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=80%"
        ];
      };
    };
  };
}
