{lib, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../user/me.nix
    ../modules/yubico.nix
  ];

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      me = {
        initialHashedPassword = lib.mkForce "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7";
        description = lib.mkForce "PAEPCKE Michael";
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
  };

  ######################
  #-=# HOME-MANAGER #=-#
  ######################
  home-manager = {
    users = {
      me = {
        home = {
          shellAliases = {
            daylight_fxl = "IATA=FXL go run paepcke.de/daylight/cmd/daylight@latest";
            daylight_ham = "IATA=HAM go run paepcke.de/daylight/cmd/daylight@latest";
            daylight_lbc = "IATA=LBC go run paepcke.de/daylight/cmd/daylight@latest";
            daylight_ber = "IATA=BER go run paepcke.de/daylight/cmd/daylight@latest";
            daylight_tls = "IATA=TLS go run paepcke.de/daylight/cmd/daylight@latest";
            wetter_fxl = "curl https://wttr.in/fxl";
            wetter_ham = "curl https://wttr.in/ham";
            wetter_lbc = "curl https://wttr.in/lbc";
            wetter_ber = "curl https://wttr.in/ber";
            wetter_tls = "curl https://wttr.in/tls";
          };
          file = {
            ".config/Yubico/u2f_keys".text = ''me:sSrgGgPQa/v0aVMtp0xJjBk4MiGQ7J69z+IOyLM6k/fllVmaqMAYepVNYMLNnMgOJI4Fkf3uyjtIJfnd4qFHmw==,lXeZ32meNOQO1xEA70CjCFn/NDl5qL3rXJn/3LY5ayvaLGvyWE6rUaVYnagNhfaoIIeYfEDvKOXvqlgpn3xoMQ==,es256,+presence'';
            ".ssh/id_ed25519_sk.pub".text = ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIA44D5TOInaQRb7DrUzMVOciR3kdXhQK9ghkjaZiZJAFAAAABHNzaDo= git@paepcke.de'';
          };
        };
        programs = {
          git = {
            userName = lib.mkForce "PAEPCKE, Michael";
            userEmail = lib.mkForce "git@paepcke.de";
            signing = {
              signByDefault = lib.mkForce false;
              key = lib.mkForce "~/.ssh/id_ed25519_sk.pub";
            };
            extraConfig = {
              init.defaultBranch = "main";
              gpg.format = "ssh";
              protocol = {
                allow = "always";
                file.allow = "always";
                git.allow = "always";
                ssh.allow = "always";
                http.allow = "always";
                https.allow = "always";
              };
              # url = {
              #  "git@github.com:" = {insteadOf = ["gh:" "github:" "https://github.com/" "https://git.github.com/"];};
              #  "git@gitlab.com:" = {insteadOf = ["gl:" "gitlab:" "https://gitlab.com/" "https://git.gitlab.com/"];};
              #  "git@codeberg.org:" = {insteadOf = ["cb:" "codeberg:" "https://codeberg.org/" "https://git.codeberg.org/"];};
              # };
            };
          };
        };
      };
    };
  };
}
