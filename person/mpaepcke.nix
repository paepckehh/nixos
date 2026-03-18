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
  users.users.me = {
    description = lib.mkForce "PAEPCKE, Michael";
    openssh.authorizedKeys.keys = lib.mkForce [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAGsgOTEwxqUCKC49pwuQHXyhb+jjIBUzFdwRsjS9iMkAAAABHNzaDo= git@paepcke.de"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIG50evljqeCBDwrkkB0FXf9A2BtCKYnDYHOnHZvpmRLNAAAABHNzaDo="
    ];
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
        };
        programs = {
          git = {
            settings = {
              init.defaultBranch = "main";
              user = {
                name = lib.mkForce "PAEPCKE, Michael";
                email = lib.mkForce "git@paepcke.de";
                signingkey = lib.mkForce "~/.ssh/id_ed25519_sk.pub";
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
