{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    dconf.settings."org/gnome/shell".favorite-apps = [
      "thunderbird.desktop"
    ];
    programs.thunderbird = {
      enable = true;
      package = pkgs.thunderbird;
      settings = infra.thunderbird.settings;
      profiles.default = {
        isDefault = true;
        settings = infra.thunderbird.settings;
      };
    };
  };
  ##################
  #-=# SERVICES #=-#
  ##################
  services.opensnitch.rules = {
    thunderbird-dns = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "thunderbird-dns";
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
            operand = "process.path";
            data = "${lib.getBin config.home-manager.users.me.programs.thunderbird.finalPackage}/lib/thunderbird/thunderbird";
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
            operand = "dest.port";
            data = "53";
            type = "simple";
            list = null;
            sensitive = false;
          }
          {
            operand = "user.id";
            data = "${toString infra.me.uid}";
            type = "simple";
            list = null;
            sensitive = false;
          }
        ];
      };
    };
    thunderbird-https = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "thunderbird-https";
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
            operand = "process.path";
            data = "${lib.getBin config.home-manager.users.me.programs.thunderbird.finalPackage}/lib/thunderbird/thunderbird";
            type = "simple";
            list = null;
            sensitive = false;
          }
          {
            operand = "dest.port";
            data = "443";
            type = "simple";
            list = null;
            sensitive = false;
          }
          {
            operand = "user.id";
            data = "${toString infra.me.uid}";
            type = "simple";
            list = null;
            sensitive = false;
          }
        ];
      };
    };
    thunderbird-imap = {
      created = infra.wg.ts.create;
      updated = infra.wg.ts.create;
      precedence = false;
      nolog = false;
      name = "thunderbird-imap";
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
            operand = "process.path";
            data = "${lib.getBin config.home-manager.users.me.programs.thunderbird.finalPackage}/lib/thunderbird/thunderbird";
            type = "simple";
            list = null;
            sensitive = false;
          }
          {
            operand = "dest.port";
            data = "143";
            type = "simple";
            list = null;
            sensitive = false;
          }
          {
            operand = "user.id";
            data = "${toString infra.me.uid}";
            type = "simple";
            list = null;
            sensitive = false;
          }
        ];
      };
    };
  };
}
