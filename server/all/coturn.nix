# coturn turn for matrix server
# age secrets: keep in sync coturn coturn-matrix, generate: pwgen -s 64 1
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
  networking = {
    extraHosts = "${infra.coturn.ip} ${infra.coturn.hostname} ${infra.coturn.fqdn}";
    firewall = {
      allowedTCPPorts = [3478 5349];
      allowedUDPPorts = [3478 5349];
      allowedUDPPortRanges = [
        {
          from = 50201;
          to = 65535;
        }
      ];
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.coturn.ip}/32";}];

  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      coturn = {
        file = ../../modules/resources/coturn.age;
        owner = "coturn";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.coturn = {};
    users = {
      coturn = {
        group = "coturn";
        isSystemUser = true;
        hashedPassword = null;
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    coturn = {
      enable = true;
      static-auth-secret-file = config.age.secrets.coturn.path;
      use-auth-secret = true;
      realm = infra.matrix.fqdn;
      listening-ips = [infra.coturn.ip];
      listening-port = 3478;
      min-port = 50201;
      max-port = 65535;
    };
  };
}
