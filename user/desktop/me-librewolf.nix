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
  bookmarks.ManagedBookmarks = lib.importJSON ../../shared/bookmarks.json;
in {
  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs.firefox = {
    enable = false;
    package = pkgs.librewolf;
    policies = infra.firefox.policy;
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    dconf.settings."org/gnome/shell".favorite-apps = [
      "librewolf.desktop"
    ];
    programs.librewolf = {
      enable = true;
      languagePacks = ["de"];
      settings = infra.firefox.settings;
      policies = lib.recursiveUpdate infra.firefox.policy bookmarks;
      profiles.default = {
        isDefault = true;
        settings = infra.firefox.settings;
      };
    };
  };
  ###############################
  #-=# HOME-MANAGER SERVICES #=-#
  ###############################
  services = {
    opensnitch = {
      rules = {
        librewolf-dns = {
          created = infra.wg.ts.create;
          updated = infra.wg.ts.create;
          precedence = false;
          nolog = false;
          name = "librewolf-dns";
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
                data = "${lib.getBin config.home-manager.users.me.programs.librewolf.finalPackage}/lib/librewolf/librewolf";
                type = "simple";
                list = null;
                sensitive = false;
              }
              {
                operand = "dest.ip";
                data = infra.dns.resolver.local;;
                type = "simple";
                list = null;
                sensitive = false;
              }
              {
                operand = "dest.port";
                data = "${toString infra.port.dns}";
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
        librewolf-https = {
          created = infra.wg.ts.create;
          updated = infra.wg.ts.create;
          precedence = false;
          nolog = false;
          name = "librewolf-https";
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
                data = "${lib.getBin config.home-manager.users.me.programs.librewolf.finalPackage}/lib/librewolf/librewolf";
                type = "simple";
                list = null;
                sensitive = false;
              }
              {
                operand = "dest.port";
                data = "${infra.port.https}";
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
        librewolf-local = {
          created = infra.wg.ts.create;
          updated = infra.wg.ts.create;
          precedence = false;
          nolog = false;
          name = "librewolf-local";
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
                data = "${lib.getBin config.home-manager.users.me.programs.librewolf.finalPackage}/lib/librewolf/librewolf";
                type = "simple";
                list = null;
                sensitive = false;
              }
              {
                operand = "dest.ip";
                data = infra.localhost.ip;
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
    };
  };
}
