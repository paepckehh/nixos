{
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      "axt" = "cd /etc/nixos/openwrt && make axt-luci";
      "dap" = "cd /etc/nixos/openwrt && make dap-luci";
      "rpi2" = "cd /etc/nixos/openwrt && make rpi2-luci";
      "b3000" = "cd /etc/nixos/openwrt && make b3000-luci";
      "axt.backup" = "cd /etc/nixos/openwrt && make axt-backup";
      "dap.backup" = "cd /etc/nixos/openwrt && make axt-dap";
      "rpi2.backup" = "cd /etc/nixos/openwrt && make rpi2-backup";
      "b3000.backup" = "cd /etc/nixos/openwrt && make b3000-backup";
      "axt.config" = "cd /etc/nixos/openwrt && make axt-config";
      "dap.config" = "cd /etc/nixos/openwrt && make dap-config";
      "rpi2.config" = "cd /etc/nixos/openwrt && make rpi2-config";
      "b3000.config" = "cd /etc/nixos/openwrt && make b3000-config";
    };
  };
}
