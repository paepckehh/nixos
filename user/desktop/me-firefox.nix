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
    # package = pkgs.firefox;
    policies = infra.firefox.policy;
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    dconf.settings."org/gnome/shell".favorite-apps = [
      "firefox.desktop"
    ];
    programs.firefox = {
      enable = true;
      languagePacks = ["de"];
      policies = lib.recursiveUpdate infra.firefox.policy bookmarks;
      profiles.default = {
        isDefault = true;
        id = 0;
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
        firefox-dns = {
          created = infra.wg.ts.create;
          updated = infra.wg.ts.create;
          precedence = false;
          nolog = false;
          name = "firefox-dns";
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
                data = "${lib.getBin config.home-manager.users.me.programs.firefox.finalPackage}/lib/firefox/firefox";
                type = "simple";
                list = null;
                sensitive = false;
              }
              {
                operand = "dest.ip";
                data = infra.dns.resolver.local;
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
        firefox-https = {
          created = infra.wg.ts.create;
          updated = infra.wg.ts.create;
          precedence = false;
          nolog = false;
          name = "firefox-https";
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
                data = "${lib.getBin config.home-manager.users.me.programs.firefox.finalPackage}/lib/firefox/firefox";
                type = "simple";
                list = null;
                sensitive = false;
              }
              {
                operand = "dest.port";
                data = "${toString infra.port.https}";
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
        firefox-local = {
          created = infra.wg.ts.create;
          updated = infra.wg.ts.create;
          precedence = false;
          nolog = false;
          name = "firefox-local";
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
                data = "${lib.getBin config.home-manager.users.me.programs.firefox.finalPackage}/lib/firefox/firefox";
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
