{
  config,
  pkgs,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################

  environment = {
    systemPackages = with pkgs; [
      libreoffice
      thunderbird
    ];
  };
}
