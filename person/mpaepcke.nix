{
  config,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../user/me.nix
  ];

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      me = {
        hashedPassword = lib.mkForce "$y$j9T$Iy95xl/8Bp1QIgxedGD4./$mnrwPShtcuWfGXV1wBmikrK4O0KupHkp1hxjrnJ9KDB";
        description = lib.mkForce "PAEPCKE Michael";
        openssh.authorizedKeys.keys = lib.mkForce ["ssh-ed25519 AAA-#locked#-"];
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
            settings = {
              init.defaultBranch = "main";
              user = {
                name = lib.mkForce "PAEPCKE, Michael";
                email = lib.mkForce "git@paepcke.de";
              };
              protocol = lib.mkForce {
                file.allow = "always";
                git.allow = "never";
                ssh.allow = "always";
                http.allow = "never";
                https.allow = "always";
              };
              signing = {
                format = "ssh";
                signByDefault = lib.mkForce false;
                key = lib.mkForce "~/.ssh/id_ed25519_sk.pub";
              };
            };
          };
        };
      };
    };
  };
}
