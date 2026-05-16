{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../siteconfig/config.nix).infra;
in {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./addOpenSnitch.nix
  ];

  ##################
  #-=# SERVICES #=-#
  ##################
  services.opensnitch.rules = {
    ##########################
    ## ALLOW DEV/ADMIN BASE ##
    ##########################
    curl = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "curl";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        data = "${lib.getBin pkgs.curl}/bin/curl";
        list = null;
        type = "simple";
        sensitive = false;
        operand = "process.path";
      };
    };
    openssh = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "openssh";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        data = "${lib.getBin pkgs.openssh}/bin/ssh";
        list = null;
        type = "simple";
        sensitive = false;
        operand = "process.path";
      };
    };
    remmina = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "remmina";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        data = "${lib.getBin pkgs.remmina}/bin/.remmina-wrapped";
        list = null;
        type = "simple";
      };
    };
  };
}
