{
  config,
  lib,
  ...
}: {
  ###########################
  #-=# UK Keyboad Layout #=-#
  ###########################
  console.keyMap = "uk";
  services.xserver.xkb.layout = "gb,de";
}
