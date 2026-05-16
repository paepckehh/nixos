# wireguard
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
  ##############
  #-=# BOOT #=-#
  ##############
  boot.kernelModules = ["wireguard"];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [wireguard-tools openssl];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    opensnitch = {
      rules = {
        wireguard-51820 = {
          created = infra.wg.ts.create;
          updated = infra.wg.ts.create;
          precedence = false;
          nolog = false;
          name = "openssh";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            operand = "list";
            data = "";
            type = "list";
            list = [
              {
                operand = "dest.port";
                data = "51820";
                type = "simple";
                list = null;
                sensitive = false;
              }
              {
                operand = "user.id";
                data = "0";
                type = "simple";
                list = null;
                sensitive = false;
              }
              {
                operand = "process.path";
                data = "Kernel connection";
                type = "simple";
                list = null;
                sensitive = false;
              }
            ];
          };
        };
      };
    };
  };
}
