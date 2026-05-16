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
  services.opensnitch = {
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
        created = infra.wg.ts.create;
        updated = infra.wg.ts.create;
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
        created = infra.wg.ts.create;
        updated = infra.wg.ts.create;
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
      ###########################
      ## ALLOW NIX BASE SYSTEM ##
      ###########################
      systemd-timesyncd = {
        created = infra.wg.ts.create;
        updated = infra.wg.ts.create;
        precedence = false;
        nolog = false;
        name = "systemd-timesyncd";
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
              data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
              list = null;
              type = "simple";
              sensitive = false;
            }
            {
              operand = "dest.port";
              data = "123";
              type = "simple";
              list = null;
              sensitive = false;
            }
            {
              operand = "user.id";
              data = "154";
              type = "simple";
              list = null;
              sensitive = false;
            }
          ];
        };
      };
      systemd-resolved = {
        created = infra.wg.ts.create;
        updated = infra.wg.ts.create;
        precedence = false;
        nolog = false;
        name = "systemd-resolved";
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
              data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
              list = null;
              type = "simple";
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
              data = "153";
              type = "simple";
              list = null;
              sensitive = false;
            }
          ];
        };
      };
      syslog-ng = {
        created = infra.wg.ts.create;
        updated = infra.wg.ts.create;
        precedence = false;
        nolog = false;
        name = "syslog-ng";
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
              data = "${lib.getBin pkgs.syslogng}/bin/syslog-ng";
              list = null;
              type = "simple";
              sensitive = false;
            }
            {
              operand = "dest.port";
              data = "514";
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
      nsncd = {
        created = infra.wg.ts.create;
        updated = infra.wg.ts.create;
        precedence = false;
        nolog = false;
        name = "nsncd";
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
              data = "${lib.getBin pkgs.nsncd}/bin/nsncd";
              list = null;
              type = "simple";
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
              data = "997";
              type = "simple";
              list = null;
              sensitive = false;
            }
          ];
        };
      };
      git-http = {
        created = infra.wg.ts.create;
        updated = infra.wg.ts.create;
        precedence = false;
        nolog = false;
        name = "git-http";
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
              data = "${lib.getBin pkgs.git}/libexec/git-core/git-remote-http";
              list = null;
              type = "simple";
              sensitive = false;
              operand = "process.path";
            }
            {
              operand = "dest.port";
              data = "443";
              type = "simple";
              list = null;
              sensitive = false;
            }
          ];
        };
      };
      nix-cli-https = {
        created = infra.wg.ts.create;
        updated = infra.wg.ts.create;
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
              operand = "dest.ip";
              data = "${infra.cache.ip}";
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
            {
              operand = "process.path";
              data = "/bin/nix";
              list = null;
              type = "regexp";
              sensitive = false;
            }
          ];
        };
      };
      nix-cli-dns = {
        created = infra.wg.ts.create;
        updated = infra.wg.ts.create;
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
            {
              operand = "process.path";
              data = "/bin/nix";
              list = null;
              type = "regexp";
              sensitive = false;
            }
          ];
        };
      };
    };
  };
}
