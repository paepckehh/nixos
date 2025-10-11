{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # environment.systemPackages = with pkgs; [thunderbird];

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    thunderbird = {
      enable = true;
    };
  };
}
