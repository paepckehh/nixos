{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [];
    shellAliases = {
      "dblab" = "CGO_ENABLED=0 go run github.com/danvergara/dblab@latest";
    };
  };
}
