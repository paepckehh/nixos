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
  ts.create = "2026-05-14T00:00:00+00:00";
in {
  ##############
  #-=# BOOT #=-#
  ##############
  # boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_latest.extend (
    lfinal: lprev: {
      opensnitch-ebpf = lprev.opensnitch-ebpf.overrideAttrs (
        old:
          assert lib.versionOlder old.version "1.8.1"; {
            preBuild =
              old.preBuild or ""
              + ''
                makeFlagsArray+=(EXTRA_FLAGS="-Wno-microsoft-anon-tag -fms-extensions")
              '';
          }
      );
    }
  );

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager.users.me.services.opensnitch-ui.enable = true;

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    opensnitch = {
      enable = true;
      settings = {
        DefaultAction = "deny";
        Firewall = "nftables";
        InterceptUnknown = true;
        LogLevel = 1;
        ProcMonitorMethod = "ebpf";
      };
      rules = {
        ###################
        ## EXPLICIT DENY ##
        ###################
        gvfs-http = {
          created = ts.create;
          updated = ts.create;
          precedence = false;
          nolog = false;
          name = "gvfs-http";
          enabled = true;
          action = "deny";
          duration = "always";
          operator = {
            data = "${lib.getBin pkgs.gvfs}/libexec/.gvfsd-http-wrapped";
            list = null;
            type = "simple";
            sensitive = false;
            operand = "process.path";
          };
        };
        gnome = {
          created = ts.create;
          updated = ts.create;
          precedence = false;
          nolog = false;
          name = "gnome";
          enabled = true;
          action = "deny";
          duration = "always";
          operator = {
            data = "gnome";
            list = null;
            operand = "process.path";
            sensitive = false;
            type = "regexp";
          };
        };
        ##################
        ## ALLOW SYSTEM ##
        ##################
        systemd-timesyncd = {
          created = ts.create;
          updated = ts.create;
          precedence = false;
          nolog = false;
          name = "systemd-timesyncd";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
            list = null;
            type = "simple";
            sensitive = false;
            operand = "process.path";
          };
        };
        systemd-resolved = {
          created = ts.create;
          updated = ts.create;
          precedence = false;
          nolog = false;
          name = "systemd-resolved";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
            list = null;
            type = "simple";
            sensitive = false;
            operand = "process.path";
          };
        };
        syslog-ng = {
          created = ts.create;
          updated = ts.create;
          precedence = false;
          nolog = false;
          name = "syslog-ng";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            data = "${lib.getBin pkgs.syslogng}/bin/syslog-ng";
            list = null;
            type = "simple";
            sensitive = false;
            operand = "process.path";
          };
        };
        nsncd = {
          created = ts.create;
          updated = ts.create;
          precedence = false;
          nolog = false;
          name = "nsncd";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            data = "${lib.getBin pkgs.nsncd}/bin/nsncd";
            list = null;
            type = "simple";
            sensitive = false;
            operand = "process.path";
          };
        };
        git-http = {
          created = ts.create;
          updated = ts.create;
          precedence = false;
          nolog = false;
          name = "git-http";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            data = "${lib.getBin pkgs.git}/libexec/git-core/git-remote-http";
            list = null;
            type = "simple";
            sensitive = false;
            operand = "process.path";
          };
        };
        nix-cli-https = {
          created = ts.create;
          updated = ts.create;
          precedence = false;
          nolog = false;
          name = "nix-cli-https";
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
                operand = "dest.host";
                data = "cache.home.corp";
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
                data = "0";
                type = "simple";
                list = null;
                sensitive = false;
              }
            ];
          };
        };
        nix-cli-dns = {
          created = ts.create;
          updated = ts.create;
          precedence = false;
          nolog = false;
          name = "nix-cli-dns";
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
                data = "0";
                type = "simple";
                list = null;
                sensitive = false;
              }
            ];
          };
        };
        ########################
        ## ALLOW DESKTOP APPS ##
        ########################
        librewolf-https = {
          created = ts.create;
          updated = ts.create;
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
                data = "443";
                type = "simple";
                list = null;
                sensitive = false;
              }
              {
                operand = "user.id";
                data = "${toString infra.admin.uid}";
                type = "simple";
                list = null;
                sensitive = false;
              }
            ];
          };
        };
        librewolf-dns = {
          created = ts.create;
          updated = ts.create;
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
                data = "${toString infra.admin.uid}";
                type = "simple";
                list = null;
                sensitive = false;
              }
            ];
          };
        };
        thunderbird = {
          created = ts.create;
          updated = ts.create;
          precedence = false;
          nolog = false;
          name = "thunderbird";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            data = "${lib.getBin config.home-manager.users.me.programs.thunderbird.finalPackage}/lib/thunderbird/thunderbird";
            list = null;
            type = "simple";
            sensitive = false;
            operand = "process.path";
          };
        };
        electron = {
          created = ts.create;
          updated = ts.create;
          precedence = false;
          nolog = false;
          name = "electron";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            data = "${lib.getBin pkgs.electron}/libexec/electron/electron";
            list = null;
            type = "simple";
            sensitive = false;
            operand = "process.path";
          };
        };
        ##########################
        ## ALLOW DEV/ADMIN BASE ##
        ##########################
        curl = {
          created = ts.create;
          updated = ts.create;
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
          created = ts.create;
          updated = ts.create;
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
        #############################
        ## ALLOW DEV/ADMIN DESKTOP ##
        #############################
        remmina = {
          created = ts.create;
          updated = ts.create;
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
            sensitive = false;
            operand = "process.path";
          };
        };
        ############################
        ## ALLOW DEV LOCAL SERVER ##
        ############################
        authelia = {
          created = ts.create;
          updated = ts.create;
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
          created = ts.create;
          updated = ts.create;
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
          created = ts.create;
          updated = ts.create;
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
          created = ts.create;
          updated = ts.create;
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
          created = ts.create;
          updated = ts.create;
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
          created = ts.create;
          updated = ts.create;
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
          created = ts.create;
          updated = ts.create;
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
          created = ts.create;
          updated = ts.create;
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
    };
  };
}
