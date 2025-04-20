{...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      "nix.iso" = ''cd /etc/nixos && make iso'';
      "nix.build" = ''cd /etc/nixos && make build'';
      "nix.switch" = ''cd /etc/nixos && make switch'';
      "nix.update" = ''cd /etc/nixos && make update'';
    };
  };
}
