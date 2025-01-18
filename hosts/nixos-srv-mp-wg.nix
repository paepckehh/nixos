{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../network/wg-client-adm.nix
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    hostName = "nixos-srv-mp-adm";
    wg-quick.interfaces."wg-pvz-adm" = {
      address = ["10.0.8.201/24"];
      privateKey = nixpkgs.lib.mkForce "8CFstz9PNB/wxoJKW2Dk5nzgd/slMUkItBcnumUB5GE=";
    };
  };
}
