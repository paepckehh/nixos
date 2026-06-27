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
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    command-not-found.enable = lib.mkForce false;
    gnupg.agent.enable = true;
    htop.enable = true;
    kbdlight.enable = true;
    fish.enable = true;
    nano.enable = true;
    mtr.enable = true;
    vim.enable = true;
    git = {
      enable = true;
      config = infra.git.client.conf;
    };
    ssh = {
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
    shellAliases = infra.shellAliases;
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
    systemPackages = with pkgs; [
      alejandra
      age-plugin-yubikey
      bashmount
      bandwhich
      bc
      bmon
      btop
      bttf
      cliqr
      cryptsetup
      delta
      dnsutils
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
      miller
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
      sqlite
      sqlite-analyzer
      sqlite-utils
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
