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
  #############
  #-=# AGE #=-#
  #############
  # age.secrets.me".file = ../modules/resources/${infra.admin.displayname}.age;

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.user.tmpfiles.rules = [
    "d ${infra.go.cache} 0770 root users"
    "L /home/me/Mounts - - - - /var/run/user/${toString infra.me.uid}/gvfs"
  ];

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      me = {
        # initialHashedPassword = null; # lockdown, use smardcard only
        # initialHashedPassword = "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7"; # start
        # initialHashedPassword = lib.mkForce config.age.secrets."me".path;
        initialHashedPassword = "$y$j9T$kfoRrF1T9PXCFCcDceKWJ1$XBjoA6ExLE5rWFPh3HEx2OkHKSpgg8Tf/50zeM5MJOB";
        description = infra.me.displayname;
        uid = infra.me.uid;
        group = "me";
        createHome = true;
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = ["users" "wheel" "backup" "networkmanager" "audio" "input" "video"];
        openssh.authorizedKeys.keys = lib.mkDefault ["ssh-ed25519 AAA-#locked#-"];
      };
    };
    groups.me = {};
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager = {
    backupFileExtension = "backup";
    useUserPackages = true;
    users = {
      me = {
        home = {
          stateVersion = config.system.nixos.release;
          enableNixpkgsReleaseCheck = false;
          homeDirectory = "/home/me";
          keyboard.layout = "us,de";
          sessionVariables = {
            # SSL_CERT_FILE = infra.pki.certs.rootCA.path;
            PAGER = "bat";
            EDITOR = "vim";
            STARSHIP_LOG = "error";
            CGO_ENABLED = "0";
          };
          shellAliases = {
            "man" = "batman";
            "cat" = "bat --paging=never";
          };
          file = {
            ".npmrc".text = ''prefix=~/.npm-packages'';
            ".config/starship.toml".source = ./resources/starship/gruvbox-rainbow.toml;
          };
        };
        fonts.fontconfig.enable = true;
        programs = {
          btop.enable = true;
          home-manager.enable = true;
          starship.enable = true;
          ripgrep.enable = true;
          delta = {
            enable = true;
            enableGitIntegration = true;
          };
          atuin = {
            enable = true;
            enableBashIntegration = false;
            enableFishIntegration = true;
            enableZshIntegration = true;
            flags = ["--disable-up-arrow"];
            settings = {
              auto_sync = false;
              dialect = "us";
              update_check = false;
              sync_address = "http://atuin.lan:8888";
              sync_frequency = "10min";
              sync.records = false;
              style = "full";
              secrets_filter = true;
              history_filter = ["LUKS" "genkey" "keygen" "private"];
            };
          };
          bat = {
            enable = true;
            extraPackages = with pkgs.bat-extras; [batman batwatch];
          };
          eza = {
            enable = true;
            git = true;
            icons = "auto";
            extraOptions = ["--group-directories-first" "--header"];
            enableBashIntegration = false;
            enableFishIntegration = true;
            enableZshIntegration = true;
          };
          fd = {
            enable = true;
            extraOptions = ["--absolute-path" "--no-ignore" "--hidden" "--ignore-case"];
          };
          fzf = {
            enable = true;
            enableBashIntegration = false;
            enableFishIntegration = false;
            enableZshIntegration = false;
          };
          git = {
            enable = true;
            settings = {
              user = {
                name = lib.mkDefault "me";
                email = lib.mkDefault "me@localhost";
                signingkey = lib.mkDefault "~/.ssh/id_ed25519_sk";
              };
              signing = {
                format = "ssh";
                signByDefault = lib.mkForce false;
              };
            };
          };
          go = {
            enable = true;
            telemetry.mode = "off";
            env = infra.go.env;
          };
          neovim = {
            enable = true;
            plugins = with pkgs.vimPlugins; [
              opencode-nvim
              coc-nvim
              go-nvim
              vim-nix
            ];
          };
          vim = {
            enable = true;
            defaultEditor = true;
            plugins = with pkgs.vimPlugins; [SudoEdit-vim vim-airline vim-shellcheck vim-git vim-nix];
            settings = {
              history = 10000;
              expandtab = true;
            };
            extraConfig = ''
              set hlsearch
              set nocompatible
              set nobackup
              if executable('nil')
              autocmd User lsp_setup call lsp#register_server({ 'name': 'nil', 'cmd': {server_info->['nil']}, 'whitelist': ['nix'],})
              endif
            '';
          };
          fish = {
            enable = true;
            interactiveShellInit = ''
              set fish_greeting # Disable greeting
              set fish_history "" # Disable history
              uname -a
            '';
          };
        };
      };
    };
  };
}
