{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      csvs-to-sqlite
      litecli
      litestream
      sqlit-tui
      sqlite
      sqlite-analyzer
      sqlite-utils
      sqlitebrowser
      sqldiff
      letsos
    ];
    shellAliases = {
      "dblab" = "CGO_ENABLED=0 go run github.com/danvergara/dblab@latest";
    };
  };
}
