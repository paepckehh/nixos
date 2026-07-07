{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = [pkgs.cifs-utils];
}
