# onlyoffice server
#
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
  networking.extraHosts = "${infra.onlyoffice.ip} ${infra.onlyoffice.hostname} ${infra.onlyoffice.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.onlyoffice.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services.caddy.virtualHosts."${infra.onlyoffice.fqdn}" = {
    listenAddresses = [infra.onlyoffice.ip];
    extraConfig = ''import intracontainer 172.16.0.${toString infra.onlyoffice.id}'';
  };

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers.${infra.onlyoffice.name} = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0";
    localAddress = "172.16.0.${toString infra.onlyoffice.id}/24";
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      ################
      #-=# SYSTEM #=-#
      ################
      system.stateVersion = "26.05";

      #################
      #-=# IMPORTS #=-#
      #################
      imports = [../../client/env.nix];

      ####################
      #-=# NETWORKING #=-#
      ####################
      networking = {
        hostName = infra.onlyoffice.hostname;
        firewall = {
          allowedTCPPorts = infra.port.webapps;
          allowedUDPPorts = infra.port.webapps;
        };
      };

      #####################
      #-=# ENVIRONMENT #=-#
      #####################
      environment.etc."onlyoffice_container_nonce".text = lib.mkForce ''
        set $secure_link_secret "onlyoffice_generated_nonce_is_not_a_secret_but_uniq";
      '';

      ##################
      #-=# SERVICES #=-#
      ##################
      services = {
        # epmd.listenStream = "0.0.0.0:4369";
        onlyoffice = {
          enable = true;
          securityNonceFile = "/etc/onlyoffice_container_nonce";
          hostname = infra.onlyoffice.fqdn;
          port = infra.port.http;
          # jwtSecretFile = config.age.secrets.onlyoffice-jwt.path;
        };
      };
    };
  };
}
