{
  config,
  pkgs,
  lib,
  ...
}: {
  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
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
    systemPackages = with pkgs; [
      alejandra
      bc
      bmon
      cliqr
      cryptsetup
      dnsutils
      dust
      fastfetch
      fd
      fzf
      gnumake
      inetutils
      jq
      lsof
      kmon
      moreutils
      nix-output-monitor
      nvme-cli
      onefetch
      openssl
      p7zip
      paper-age
      parted
      passage
      progress
      pv
      pwgen
      rage
      smartmontools
      tldr
      tree
      tz
      libsmbios
      unzip
      wireguard-tools
      yq
      yubikey-manager
    ];
  };
}
