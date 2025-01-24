{
  config,
  disko,
  lib,
  ...
}: {
  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    initrd = {
      availableKernelModules = ["aesni_intel" "cryptd"];
      luks = {
        mitigateDMAAttacks = lib.mkForce true;
        devices = {
          "root" = {
            device = "/dev/disk/by-partlabel/disk-main-root";
            allowDiscards = true;
          };
        };
      };
    };
  };


  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.etc."luks".text = lib.mkForce ''start'';

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
              root = {
                size = "100%";
                content = {
                  initrdUnlock = true;
                  name = "root";
                  type = "luks";
                  passwordFile = "/etc/luks";
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
                    mountpoint = "/";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
