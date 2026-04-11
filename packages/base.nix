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
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    pcscd = {
      enable = true;
      plugins = [pkgs.ccid];
    };
    udev.packages = [pkgs.yubikey-personalization];
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
    yubikey-manager.enable = true;
    git = {
      enable = true;
      config = infra.git.client.conf;
    };
    ssh = {
      extraConfig = "AddKeysToAgent yes";
      hostKeyAlgorithms = ["ssh-ed25519" "sk-ssh-ed25519@openssh.com"];
      pubkeyAcceptedKeyTypes = ["ssh-ed25519" "sk-ssh-ed25519@openssh.com"];
      ciphers = ["chacha20-poly1305@openssh.com"];
      kexAlgorithms = ["curve25519-sha256" "curve25519-sha256@libssh.org"];
      knownHosts = infra.ssh.knownHosts;
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    interactiveShellInit = ''uname -a'';
    shells = [pkgs.bashInteractive pkgs.fish];
    shellAliases = {
      "e" = "vim";
      "b" = "sudo btop";
      "d" = "sudo dmesg";
      "l" = "ls -la";
      "n" = "cd /etc/nixos && ls -la";
      "h" = "htop --tree --highlight-changes";
      "cron.list" = "systemctl list-timers --all";
      "service.log.clean" = "sudo journalctl --vacuum-time=1d";
      "service.log.follow" = "sudo journalctl --follow -u $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.log.today" = "sudo journalctl --pager-end --since today -u $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.start" = "sudo systemctl start $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.stop" = "sudo systemctl stop $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.status" = "sudo systemctl status $(systemctl list-units --type=service | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "service.restart" = "sudo systemctl restart $(systemctl list-units --type=service --all | fzf | sed 's/●/ /g' | cut --fields 3 --delimiter ' ')";
      "log.boot" = "sudo dmesg --follow --human --kernel --userspace";
      "log.system" = "sudo journalctl --follow --priority=7 --lines=2500";
      "log.time" = "systemctl status chronyd ; chronyc tracking ; chronyc sources ; chronyc sourcestats ; sudo chronyc authdata ; sudo chronyc serverstats";
      "time.status" = "timedatectl timesync-status";
      "info.nvme.extern" = "sudo smartctl --all /dev/sda";
      "info.nvme.intern" = "sudo smartctl --all /dev/nvme0";
      "portal" = "xdg-open http://$(ip --oneline route get 1.1.1.1 | awk '{print $3}')";
      "ventoy.gui" = "NIXPKGS_ALLOW_INSECURE=1 NIXPKGS_ALLOW_UNFREE=1 nix-shell -p ventoy-full-gtk --run ventoy-gui";
      "ll" = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename";
      "la" = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=size";
      "lg" = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --group";
      "lt" = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --tree";
      "lo" = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=filename --octal-permissions";
      "li" = "eza --all --long --total-size --group-directories-first --header --git --git-repos --sort=inode --inode";
    };
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
      ROC_ENABLE_PRE_VEGA = "1";
    };
    systemPackages = with pkgs; [
      alejandra
      bashmount
      bandwhich
      bc
      bmon
      btop
      cliqr
      cryptsetup
      delta
      dnsutils
      duf
      dust
      eza
      fastfetch
      fd
      fzf
      grc
      gnumake
      gnupg
      inetutils
      igrep
      jq
      kmon
      libsmbios
      lsof
      moreutils
      nix-output-monitor
      nvme-cli
      openssl
      p7zip
      paper-age
      pam_u2f
      parted
      passage
      progress
      pwgen
      pv
      rage
      ripgrep
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
