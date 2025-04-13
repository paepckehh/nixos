{...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      "openwrt.build.generic.dlink.dap-1860-a1" = ''
        cd /etc/nixos/openwrt &&\
        nix build #generic-dlink_dap-x1860-a1'';
    };
  };
}
