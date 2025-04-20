{
  ###############
  #-=# DISKO #=-#
  ###############
  disko = {
    devices = {
      disk = {
        main = {
          device = "/dev/sdb";
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
              primary = {
                size = "100%";
                content = {
                  type = "lvm_pv";
                  vg = "mainpool";
                };
              };
            };
          };
        };
      };
      lvm_vg = {
        mainpool = {
          type = "lvm_vg";
          lvs = {
            thinpool = {
              size = "100%";
              lvm_type = "thin-pool";
            };
            root = {
              size = "100M";
              lvm_type = "thinlv";
              pool = "thinpool";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = ["noatime" "nodiratime" "discard"];
              };
            };
            nix = {
              size = "100M";
              lvm_type = "thinlv";
              pool = "thinpool";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
                mountOptions = ["noatime" "nodiratime" "discard"];
              };
            };
            home = {
              size = "100M";
              lvm_type = "thinlv";
              pool = "thinpool";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
                mountOptions = ["noatime" "nodiratime" "discard"];
              };
            };
            var = {
              size = "100M";
              lvm_type = "thinlv";
              pool = "thinpool";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/var";
                mountOptions = ["noatime" "nodiratime" "discard"];
              };
            };
          };
        };
      };
    };
  };
}
