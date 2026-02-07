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
    openssh.authorizedKeys.keys = ["sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAGsgOTEwxqUCKC49pwuQHXyhb+jjIBUzFdwRsjS9iMkAAAABHNzaDo= git@paepcke.de"];
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
            # yubikey private key handle
            ".ssh/id_ed25519_sk".text = ''
              -----BEGIN OPENSSH PRIVATE KEY-----
              b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAASgAAABpzay1zc2
              gtZWQyNTUxOUBvcGVuc3NoLmNvbQAAACABrIDkxMMalAiguPacLkB18oW/o4yAVMxXcEbI
              0vYjJAAAAARzc2g6AAAA8O6alwTumpcEAAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY2
              9tAAAAIAGsgOTEwxqUCKC49pwuQHXyhb+jjIBUzFdwRsjS9iMkAAAABHNzaDoBAAAAgPqg
              5evHnZf1UWKRiy5WFmRdS22284ElPmxMTNB+9AEx+gXyeA2bn/rn/m8hm5b+SOZOz/ZB6x
              mrM5Iy0zbrPZGnPMlb3+/icOmaVbFodvH2EWAKHo9P8D2An7v+B0Etyh0aozewwX8O2mtS
              SzNv89bI6B8a7UQcHxvjKYqTAv7rAAAAAAAAAA5naXRAcGFlcGNrZS5kZQECAw==
              -----END OPENSSH PRIVATE KEY-----
            '';
            ".ssh/id_ed25519_sk.pub".text = ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAGsgOTEwxqUCKC49pwuQHXyhb+jjIBUzFdwRsjS9iMkAAAABHNzaDo= git@paepcke.de'';
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
