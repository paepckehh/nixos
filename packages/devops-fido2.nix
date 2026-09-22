{pkgs, ...}: {
  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs.passless = {
    enable = false;
    users = ["me"];
  };

  ##################
  #-=# SERVICES #=-#
  ##################

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      libfido2
      fido2-manage
    ];
  };
}
