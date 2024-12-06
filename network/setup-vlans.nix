{
  config,
  lib,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    vlans = {
      "setup" = {
        id = 4096; # vlan id 4096 -> dedicated setup vlan (temporary)
        interface = "eth0";
      };
    };
    interfaces = {
      # complete device setup list(s):
      # https://www.techspot.com/guides/287-default-router-ip-addresses
      "setup".ipv4.addresses = [
        {
          address = "192.168.0.250";
          prefixLength = 24;
          # .1   [dlink|unifi|linksys|netgear...] setup
          # .3   [sonicwall] setup
          # .50  [dlink] recovery-boot-loader
          # .227 [netgear] recovery
        }
        {
          address = "192.168.1.250";
          prefixLength = 24;
          # .1   [openwrt|freifunk|tp|linksys|...] setup
        }
        {
          address = "192.168.2.250";
          prefixLength = 24;
          # .1 [linksys|tp-link]|... setup
        }
        {
          address = "192.168.3.250";
          prefixLength = 24;
          # .1 [sonicwall] setup
        }
        {
          address = "192.168.4.250";
          prefixLength = 24;
          # .1 [zyxel] setup
        }
        {
          address = "192.168.8.250";
          prefixLength = 32; # fixme
          # .1 [gl-inet] setup
        }
        {
          address = "192.168.178.250";
          prefixLength = 24;
          # .1 [avm|fritz] setup
        }
        {
          address = "192.168.254.250";
          prefixLength = 24;
          # .254 [zyxel] setup
        }
      ];
    };
  };
}
