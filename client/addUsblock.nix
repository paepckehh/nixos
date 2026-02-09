{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../siteconfig/config.nix).infra;
in {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    usbguard = {
      enable = true;
      rules = ''
        allow with-interface all-of { 03:*:* } # HID
        allow with-interface all-of { 08:*:* } # Storage
        reject with-interface all-of { 08:*:* 03:00:* }
        reject with-interface all-of { 08:*:* 03:01:* }
        reject with-interface all-of { 08:*:* e0:*:* }
        reject with-interface all-of { 08:*:* 02:*:* }
        allow with-interface one-of { 03:00:01 03:01:01 } if !allowed-matches(with-interface one-of { 03:00:01 03:01:01 })
      '';
    };
  };
}
