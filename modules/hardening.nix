{
  config,
  pkgs,
  lib,
  ...
}: {
  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    kernelParams = ["slab_nomerge" "page_poison=1" "page_alloc.shuffle=1" "ipv6.disable=1"];
  };
}
