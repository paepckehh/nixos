{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      golangci-lint
      gopls
      gofumpt
      go-tools
    ];
  };
}
