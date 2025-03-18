{
  pkgs,
  lib,
  ...
}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    interactiveShellInit = ''uname -a && eval "$(ssh-agent)"'';
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
      ROC_ENABLE_PRE_VEGA = "1";
    };
    shells = [pkgs.bashInteractive pkgs.zsh];
    shellAliases = {
      e = "vim";
      l = "ls -la";
      d = "sudo dmesg --follow --human --kernel --userspace";
      slog = "journalctl --follow --priority=7 --lines=2500";
      nvmeinfo = "sudo smartctl --all /dev/sda"; # /dev/nvme0
      "service.log" = "journalctl --since='30 min ago' -u $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.start" = "sudo systemctl start $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.stop" = "sudo systemctl stop $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.status" = "sudo systemctl status $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.restart" = "sudo systemctl restart $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
    };
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    htop.enable = true;
    iotop.enable = true;
    kbdlight.enable = true;
    nano.enable = true;
    mtr.enable = true;
    usbtop.enable = true;
    vim.enable = true;
    zsh.enable = true;
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
    systemPackages = with pkgs; [
      alejandra
      amdgpu_top
      arp-scan
      bandwhich
      bmon
      certinfo-go
      cliqr
      dmidecode
      dnsutils
      dust
      fastfetch
      fd
      fzf
      gnumake
      gping
      inetutils
      jq
      kmon
      moreutils
      ncdu
      nix-output-monitor
      nix-top
      nix-tree
      nvme-cli
      onefetch
      openssl
      p7zip
      paper-age
      parted
      passage
      pciutils
      progress
      pv
      pwgen
      sysz
      s-tui
      smartmontools
      tldr
      tlsinfo
      tree
      trippy
      tz
      libsmbios
      unzip
      usbutils
      wireguard-tools
      yamlfmt
      yq
      yubikey-manager
    ];
  };
}
