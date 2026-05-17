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
  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me = {
    dconf.settings."org/gnome/shell".favorite-apps = [
      "element-desktop.desktop"
    ];
    programs.element-desktop = {
      enable = true;
      settings = {
        default_server_config = {
          "m.homeserver" = {
            base_url = infra.matrix.url;
            server_name = "${infra.site.name}TALK";
          };
          "m.identity_server" = {
            base_url = "https://vector.im";
          };
        };
        disable_custom_urls = false;
        disable_guests = false;
        disable_login_language_selector = false;
        disable_3pid_login = false;
        force_verification = false;
        brand = "Element";
        integrations_ui_url = "https://scalar.vector.im/";
        integrations_rest_url = "https://scalar.vector.im/api";
      };
    };
  };
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    opensnitch = {
      rules = {
        element = {
          created = infra.wg.ts.create;
          updated = infra.wg.ts.create;
          precedence = false;
          nolog = false;
          name = "element";
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
                operand = "dest.ip";
                data = infra.matrix.ip;
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
              {
                operand = "process.path";
                data = "electron";
                list = null;
                type = "regexp";
                sensitive = false;
              }
            ];
          };
        };
      };
    };
  };
}
