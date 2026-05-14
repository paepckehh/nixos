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
          created = "2026-05-14T00:00:00+00:00";
          name = "gvfs-http";
          enabled = true;
          action = "deny";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.gvfs}/libexec/.gvfsd-http-wrapped";
          };
        };
        gsd-print-notifications = {
          created = "2026-05-14T00:00:00+00:00";
          name = "gvfs-http";
          enabled = true;
          action = "deny";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.gnome-settings-daemon}/libexec/.gsd-print-notifications-wrapped";
          };
        };
        ##################
        ## ALLOW SYSTEM ##
        ##################
        systemd-timesyncd = {
          created = "2026-05-14T00:00:00+00:00";
          name = "systemd-timesyncd";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
          };
        };
        systemd-resolved = {
          created = "2026-05-14T00:00:00+00:00";
          name = "systemd-resolved";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
          };
        };
        syslog-ng = {
          created = "2026-05-14T00:00:00+00:00";
          name = "syslog-ng";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.syslogng}/bin/syslog-ng";
          };
        };
        nsncd = {
          created = "2026-05-14T00:00:00+00:00";
          name = "nsncd";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.nsncd}/bin/nsncd";
          };
        };
        nix-cli-bin = {
          created = "2026-05-14T00:00:00+00:00";
          name = "nix-cli-bin";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getExe config.nix.package.nix-cli}/bin/nix";
            # data = "${lib.getExe config.nix.package}/bin/nix";
            # data = "${lib.getExe config.nix.package}/bin/nix";
            # data = "${lib.getExe config.nix.package}/bin/nix";
          };
        };
        git-http = {
          created = "2026-05-14T00:00:00+00:00";
          name = "git-http";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.git}/libexec/git-core/git-remote-http";
          };
        };
        ########################
        ## ALLOW DESKTOP APPS ##
        ########################
        librewolf = {
          created = "2026-05-14T00:00:00+00:00";
          name = "librewolf";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin config.home-manager.users.me.programs.librewolf.finalPackage}/lib/librewolf/librewolf";
          };
        };
        thunderbird = {
          created = "2026-05-14T00:00:00+00:00";
          name = "thunderbird";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin config.home-manager.users.me.programs.thunderbird.finalPackage}/lib/thunderbird/thunderbird";
          };
        };
        electron = {
          created = "2026-05-14T00:00:00+00:00";
          name = "electron";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.electron}/libexec/electron/electron";
          };
        };
        ##########################
        ## ALLOW DEV/ADMIN BASE ##
        ##########################
        curl = {
          created = "2026-05-14T00:00:00+00:00";
          name = "curl";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.curl}/bin/curl";
          };
        };
        openssh = {
          created = "2026-05-14T00:00:00+00:00";
          name = "openssh";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.openssh}/bin/ssh";
          };
        };
        #############################
        ## ALLOW DEV/ADMIN DESKTOP ##
        #############################
        remmina = {
          created = "2026-05-14T00:00:00+00:00";
          name = "remmina";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.remmina}/bin/.remmina-wrapped";
          };
        };
        ############################
        ## ALLOW DEV LOCAL SERVER ##
        ############################
        authelia = {
          created = "2026-05-14T00:00:00+00:00";
          name = "authelia";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.authelia}/bin/authelia";
          };
        };
        bind = {
          created = "2026-05-14T00:00:00+00:00";
          name = "bind";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.bind}/bin/named";
          };
        };
        caddy = {
          created = "2026-05-14T00:00:00+00:00";
          name = "caddy";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.caddy}/bin/caddy";
          };
        };
        ncps = {
          created = "2026-05-14T00:00:00+00:00";
          name = "ncsp";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.ncps}/bin/.ncps-wrapped";
          };
        };
        maddy = {
          created = "2026-05-14T00:00:00+00:00";
          name = "maddy";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.maddy}/bin/maddy";
          };
        };
        ollama = {
          created = "2026-05-14T00:00:00+00:00";
          name = "ollam";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.ollama}/bin/ollama";
          };
        };
        # searX, replace asap!
        python3 = {
          created = "2026-05-14T00:00:00+00:00";
          name = "python3";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.python3}/bin/python3";
          };
        };
      };
    };
  };
}
