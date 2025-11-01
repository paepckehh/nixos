{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [eclipses.eclipse-platform];
    shellAliases = {};
  };
  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [golang.go ms-python.python];
    };
  };
}
