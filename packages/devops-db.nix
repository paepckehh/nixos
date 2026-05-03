{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      csvs-to-sqlite
      litecli
      litestream
      sqlar
      sqlit-tui
      sqlite
      sqlite-analyzer
      sqlite-utils
      sqlitebrowser
      sqldiff
      sqlitestudio
    ];
    shellAliases = {
      "dblab" = "CGO_ENABLED=0 go run github.com/danvergara/dblab@latest";
    };
  };
}
