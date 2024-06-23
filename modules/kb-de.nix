{
  config,
  lib,
  ...
}: {
  ###########################
  #-=# DE Keyboad Layout #=-#
  ###########################
  console.keyMap = "de";
  services.xserver.xkb.layout = "de,gb";
}
