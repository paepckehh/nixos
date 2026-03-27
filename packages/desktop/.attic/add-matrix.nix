{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [element-desktop];
}
