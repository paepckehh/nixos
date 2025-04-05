{config, pkgs, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    syslog-ng = {
      enable = true;
      extraConfig = "";
      extraModulePaths = [];
      package = pkgs.syslogng;
  };
    ##############
    # NETWORKING #
    ##############
    networking = {
      firewall = {
        allowedTCPPorts = [];
        allowedUDPPorts = [];
      };
    };
}
