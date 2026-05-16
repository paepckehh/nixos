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
    ############################
    ## ALLOW DEV LOCAL SERVER ##
    ############################
    authelia = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "authelia";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        data = "${lib.getBin pkgs.authelia}/bin/authelia";
        list = null;
        type = "simple";
        sensitive = false;
        operand = "process.path";
      };
    };
    bind = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "bind";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        data = "${lib.getBin pkgs.bind}/bin/named";
        list = null;
        type = "simple";
        sensitive = false;
        operand = "process.path";
      };
    };
    caddy = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "caddy";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        data = "${lib.getBin pkgs.caddy}/bin/caddy";
        list = null;
        type = "simple";
        sensitive = false;
        operand = "process.path";
      };
    };
    ncps = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "ncsp";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        data = "${lib.getBin pkgs.ncps}/bin/.ncps-wrapped";
        list = null;
        type = "simple";
        sensitive = false;
        operand = "process.path";
      };
    };
    maddy = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "maddy";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        data = "${lib.getBin pkgs.maddy}/bin/maddy";
        list = null;
        type = "simple";
        sensitive = false;
        operand = "process.path";
      };
    };
    ollama = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "ollam";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        data = "${lib.getBin pkgs.ollama}/bin/ollama";
        list = null;
        type = "simple";
        sensitive = false;
        operand = "process.path";
      };
    };
    searX-https = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "searX-https";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        data = "";
        sensitive = false;
        operand = "list";
        type = "list";
        list = [
          {
            operand = "dest.port";
            data = "443";
            type = "simple";
            list = null;
            sensitive = false;
          }
          {
            operand = "user.id";
            data = "${toString infra.search.uid}";
            type = "simple";
            list = null;
            sensitive = false;
          }
          {
            operand = "process.path";
            data = "python3";
            type = "regexp";
            list = null;
            sensitive = false;
          }
        ];
      };
    };
    searX-dns = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "searX-dns";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        data = "";
        sensitive = false;
        operand = "list";
        type = "list";
        list = [
          {
            operand = "dest.port";
            data = "53";
            type = "simple";
            list = null;
            sensitive = false;
          }
          {
            operand = "dest.ip";
            data = "127.0.0.53";
            type = "simple";
            list = null;
            sensitive = false;
          }
          {
            operand = "user.id";
            data = "${toString infra.search.uid}";
            type = "simple";
            list = null;
            sensitive = false;
          }
          {
            operand = "process.path";
            data = "python3";
            type = "regexp";
            list = null;
            sensitive = false;
          }
        ];
      };
    };
  };
}
