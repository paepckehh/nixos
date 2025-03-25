{
  config,
  lib,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.etc."paperless-adm.conf".text = "admin";

  ##################
  #-=# SERVICES #=-#
  ##################
  services.paperless = {
    enable = true;
    passwordFile = "/etc/paperless-adm.conf";
  };
}
