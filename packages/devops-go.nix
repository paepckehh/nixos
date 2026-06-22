{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      go
      golangci-lint
      gopls
      gofumpt
      gotools
      go-tools
    ];
  };
}
