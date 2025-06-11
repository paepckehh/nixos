{
  pkgs,
  lib,
  ...
}: {
  services.proxmox-ve = {
    enable = true;
    ipAddress = "127.0.0.1";
  };
}
