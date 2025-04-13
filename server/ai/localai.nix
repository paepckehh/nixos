{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      localai
    ];
  };
}
