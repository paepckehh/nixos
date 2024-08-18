{
  config,
  lib,
  home-manager,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./luks.me
    ../user/me.nix
  ];


  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      me = {
        initialHashedPassword = lib.mkForce "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7";
        description = lib.mkForce "PAEPCKE Michael env admin";
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
         home.file = {".config/Yubico/u2f_keys".text = ''me:sSrgGgPQa/v0aVMtp0xJjBk4MiGQ7J69z+IOyLM6k/fllVmaqMAYepVNYMLNnMgOJI4Fkf3uyjtIJfnd4qFHmw==,lXeZ32meNOQO1xEA70CjCFn/NDl5qL3rXJn/3LY5ayvaLGvyWE6rUaVYnagNhfaoIIeYfEDvKOXvqlgpn3xoMQ==,es256,+presence''
        programs = {
          git = {
            userName = lib.mkForce "PAEPCKE, Michael";
            userEmail = lib.mkForce "git@github.com";
            signing = {
              signByDefault = lib.mkForce true;
              key = lib.mkForce "~/.ssh/id_ed25519_sk.pub";
            };
            extraConfig = {
              protocol = {
                allow = "never";
                file.allow = "always";
                git.allow = "never";
                ssh.allow = "always";
                http.allow = "never";
                https.allow = "never";
              };
              url = {
                "git@github.com:" = {insteadOf = ["gh:" "github:" "https://github.com/" "https://git.github.com/"];};
                "git@gitlab.com:" = {insteadOf = ["gl:" "gitlab:" "https://gitlab.com/" "https://git.gitlab.com/"];};
                "git@codeberg.org:" = {insteadOf = ["cb:" "codeberg:" "https://codeberg.org/" "https://git.codeberg.org/"];};
              };
            };
          };
        };
      };
    };
  };
}

