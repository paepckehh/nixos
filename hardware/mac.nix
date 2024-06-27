{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: {
  boot.kernelPatches = [
    {
      name = "bcrm-config";
      patch = null;
      extraConfig = ''
        BT_HCIUART_BCM y
        SND_HDA_CODEC_CS8409 m
      '';
    }
  ];
}
