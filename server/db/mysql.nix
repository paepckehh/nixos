{
  config,
  pkgs,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  # environment.systemPackages = with pkgs; [];

  ##################
  #-=# SERVICES #=-#
  ##################
  # prometheus.exporters.mysql.enable = false;
  services = {
    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };
  };
}
