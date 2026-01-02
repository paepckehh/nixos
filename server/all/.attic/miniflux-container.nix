{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.miniflux.ip} ${infra.miniflux.hostname} ${infra.miniflux.fqdn}";

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.miniflux.fqdn}" = {
      listenAddresses = [infra.miniflux.ip];
      extraConfig = ''import intraproxy ${toString infra.miniflux.localbind.port.http}'';
    };
  };

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers.miniflux = {
    autoStart = true;
    privateNetwork = false;
    hostAddress = infra.miniflux.ip;
    config = {
      agenix,
      config,
      pkgs,
      lib,
      ...
    }: {
      #############
      #-=# AGE #=-#
      #############
      # age = {
      #  secrets = {
      #    miniflux = {
      #      file = ../../modules/resources/miniflux.age; # env file, must contain ADMIN_USERNAME="" and ADMIN_PASSWORD=""
      #      owner = "miniflux";
      #      group = "miniflux";
      #    };
      #  };
      # };

      ###############
      #-=# USERS #=-#
      ###############
      # users = {
      #  groups.miniflux = {};
      #  users = {
      #    miniflux = {
      #      group = "miniflux";
      #      isSystemUser = true;
      #      hashedPassword = null; # disable ldap service account interactive logon
      #      openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      #    };
      #  };
      # };

      ################
      #-=# SYSTEM #=-#
      ################
      system.stateVersion = "26.05";

      #################
      #-=# SYSTEMD #=-#
      #################
      systemd.services.miniflux = {
        after = ["sockets.target"];
        wants = ["sockets.target"];
        wantedBy = ["multi-user.target"];
      };

      ##################
      #-=# SERVICES #=-#
      ##################
      services = {
        miniflux = {
          enable = true;
          # adminCredentialsFile = config.age.secrets.miniflux.path;
          config = {
            CREATE_ADMIN = false;
            LISTEN_ADDR = "${infra.localhost.ip}:${toString infra.miniflux.localbind.port.http}";
          };
        };
      };
    };
  };
}
