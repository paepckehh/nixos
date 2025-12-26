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
  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      miniflux = {
        # ADMIN_USERNAME=""
        # ADMIN_PASSWORD=""
        file = ../../modules/resources/miniflux.age;
        owner = "miniflux";
        group = "miniflux";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.miniflux = {};
    users = {
      miniflux = {
        group = "miniflux";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.rss.namespace}.addresses = [
    {Address = "${infra.rss.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.rss.ip} ${infra.rss.hostname} ${infra.rss.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    miniflux = {
      enable = true;
      adminCredentialsFile = config.age.secrets.miniflux.path;
      config = {
        CREATE_ADMIN = true;
        LISTEN_ADDR = "${infra.rss.localbind.ip}:${toString infra.rss.localbind.port.http}";
      };
    };
  };
}
