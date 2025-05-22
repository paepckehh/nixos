{
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      # base
      "axt" = "cd /etc/nixos/openwrt && make axt-luci";
      "dap" = "cd /etc/nixos/openwrt && make dap-luci";
      "rpi2" = "cd /etc/nixos/openwrt && make rpi2-luci";
      "b3000" = "cd /etc/nixos/openwrt && make b3000-luci";
      # btop
      "axt.btop" = "cd /etc/nixos/openwrt && make axt-btop";
      "dap.btop" = "cd /etc/nixos/openwrt && make dap-btop";
      "rpi2.btop" = "cd /etc/nixos/openwrt && make rpi2-btop";
      "b3000.btop" = "cd /etc/nixos/openwrt && make b3000-btop";
      # backup
      "axt.backup" = "cd /etc/nixos/openwrt && make axt-backup";
      "dap.backup" = "cd /etc/nixos/openwrt && make axt-dap";
      "rpi2.backup" = "cd /etc/nixos/openwrt && make rpi2-backup";
      "b3000.backup" = "cd /etc/nixos/openwrt && make b3000-backup";
      # config
      "axt.config" = "cd /etc/nixos/openwrt && make axt-config";
      "dap.config" = "cd /etc/nixos/openwrt && make dap-config";
      "rpi2.config" = "cd /etc/nixos/openwrt && make rpi2-config";
      "b3000.config" = "cd /etc/nixos/openwrt && make b3000-config";
      # moode
      "moode" = "ssh -p 6623 me@moode.lan";
      "moode.btop" = "ssh -t -p 6623 me@moode.lan 'btop --utf-force'";
      "moode.ro" = "ssh -p 6623 me@moode.lan 'sh /home/me/ro.sh && sudo reboot'";
      "moode.rw" = "ssh -p 6623 me@moode.lan 'sh /home/me/rw.sh && sudo reboot'";
      "moode.reboot" = "ssh -p 6623 me@moode.lan 'sudo reboot'";
    };
  };
}
