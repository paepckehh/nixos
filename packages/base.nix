{
  config,
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    pcscd.enable = true;
    yubikey-agent.enable = true;
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    command-not-found.enable = lib.mkForce false;
    htop.enable = true;
    kbdlight.enable = true;
    fish.enable = true;
    nano.enable = true;
    mtr.enable = true;
    vim.enable = true;
    zsh = {
      enable = true;
      histFile = "/dev/null";
      histSize = 0;
    };
    ssh = {
      startAgent = lib.mkForce true;
      extraConfig = "AddKeysToAgent yes";
      hostKeyAlgorithms = ["ssh-ed25519" "sk-ssh-ed25519@openssh.com"];
      pubkeyAcceptedKeyTypes = ["ssh-ed25519" "sk-ssh-ed25519@openssh.com"];
      ciphers = ["chacha20-poly1305@openssh.com"];
      kexAlgorithms = ["curve25519-sha256" "curve25519-sha256@libssh.org"];
      knownHosts = {
        github = {
          extraHostNames = ["github.com" "api.github.com" "git.github.com"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
        gitlab = {
          extraHostNames = ["gitlab.com" "api.gitlab.com" "git.gitlab.com"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
        };
        codeberg = {
          extraHostNames = ["codeberg.org" "api.codeberg.org" "git.codeberg.org"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
        };
        sourcehut = {
          extraHostNames = ["sr.ht" "api.sr.ht" "git.sr.ht"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
        };
      };
    };
    git = {
      enable = true;
      prompt.enable = true;
      config = {
        branch.sort = "-committerdate";
        commit.gpgsign = false;
        init.defaultBranch = "main";
        safe.directory = "*";
        gpg.format = "ssh";
        user = {
          email = "nix@nixos.local";
          name = "NIXOS, Generic Local";
          signingkey = "~/.ssh/id_ed25519.pub";
        };
        http = {
          sslVerify = "true";
          sslVersion = "tlsv1.3";
          version = "HTTP/1.1";
        };
        protocol = {
          allow = "always";
          file.allow = "always";
          git.allow = "always";
          ssh.allow = "always";
          http.allow = "always";
          https.allow = "always";
        };
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    interactiveShellInit = ''uname -a'';
    shells = [pkgs.bashInteractive pkgs.zsh pkgs.fish];
    shellAliases = {
      "e" = "vim";
      "l" = "ls -la";
      "log.boot" = "sudo dmesg --follow --human --kernel --userspace";
      "log.system" = "journalctl --follow --priority=7 --lines=2500";
      "info.nvme.extern" = "sudo smartctl --all /dev/sda";
      "info.nvme.intern" = "sudo smartctl --all /dev/nvme0";
      "service.log.clean" = "sudo journalctl --vacuum-time=1d";
      "service.log.follow" = "sudo journalctl --follow -u $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.log.today" = "sudo journalctl --pager-end --since today -u $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.start" = "sudo systemctl start $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.stop" = "sudo systemctl stop $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.status" = "sudo systemctl status $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.restart" = "sudo systemctl restart $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
    };
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
      ROC_ENABLE_PRE_VEGA = "1";
    };
    systemPackages = with pkgs; [
      alejandra
      bashmount
      bmon
      bc
      cliqr
      cryptsetup
      delta
      disko
      dnsutils
      duf
      dust
      fastfetch
      fd
      fzf
      grc
      gnumake
      fishPlugins.autopair
      fishPlugins.fish-you-should-use
      fishPlugins.grc
      inetutils
      jq
      kmon
      libsmbios
      lsof
      moreutils
      nix-output-monitor
      nvme-cli
      onefetch
      openssl
      p7zip
      paper-age
      pam_u2f
      parted
      passage
      progress
      pwgen
      pv
      smartmontools
      tldr
      tree
      tz
      unzip
      yq
      yubikey-manager
      zip
    ];
  };
}
