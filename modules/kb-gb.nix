{
  config,
  lib,
  ...
}: {
  ###########################
  #-=# GB Keyboad Layout #=-#
  ###########################
  console.keyMap = "gb";
  services.xserver.xkb.layout = "gb,de";
}
