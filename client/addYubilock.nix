{
  config,
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    udev.extraRules = ''
      ACTION=="remove",\
      ENV{ID_BUS}=="usb",\
      ENV{ID_MODEL_ID}=="*",\
      ENV{ID_VENDOR_ID}=="1050",\
      ENV{ID_VENDOR}=="Yubico",\
      RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
    '';
  };
}
