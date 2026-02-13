# dumbdrop simple file sharing
# sudo mkdir -p /var/lib/dumbdrop/share
# sudo chown -R 1000:1000 /var/lib/dumbdrop
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
  networking.extraHosts = "${infra.dumbdrop.ip} ${infra.dumbdrop.hostname} ${infra.dumbdrop.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.dumbdrop.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.dumbdrop.fqdn}" = {
      listenAddresses = [infra.dumbdrop.ip];
      extraConfig = ''import intraproxy ${toString infra.dumbdrop.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        dumbdrop = {
          image = "dumbwareio/dumbdrop:latest";
          ports = ["${infra.localhost.ip}:${toString infra.dumbdrop.localbind.port.http}:3000"];
          volumes = ["/var/lib/dumbdrop/uploads:/app/uploads"];
          environment = {
            # TRUST_PROXY = "true";
            # TRUSTED_PROXY_IPS = "10.20.0.100";
            # DUMBDROP_PIN = "464";
            DUMBDROP_TITLE = "Drop";
            MAX_FILE_SIZE = "256"; # MB
            SET_SERVER_NAME = "${infra.dumbdrop.fqdn}";
          };
        };
      };
    };
  };
}
