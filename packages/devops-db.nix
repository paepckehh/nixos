{
  config,
  pkgs,
  lib,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      ldapvi
    ];
    shellAliases = {
      "dblab" = "CGO_ENABLED=0 go run github.com/danvergara/dblab@latest";
      "godap" = "CGO_ENABLED=0 go run github.com/macmod/godap@latest";
      "moribito" = "CGO_ENABLED=0 go run github.com/ericschmar/moribito/cmd/moribito@latest";
    };
  };
}
