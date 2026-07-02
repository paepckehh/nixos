# rustdesk signal and relay
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
    extraHosts = "${infra.rustdesk.ip} ${infra.rustdesk.hostname} ${infra.rustdesk.fqdn}";
    firewall = {
      allowedUDPPorts = [21116];
      allowedTCPPortRanges = [
        {
          from = 21114;
          to = 21119;
        }
      ];
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.rustdesk.ip}/32";}];
    services = {
      rustdesk-signal.environment = {
        ALWAYS_USE_RELAY = "Y";
        RUST_LOG = "debug";
      };
      rustdesk-relay.environment = {
        RUST_LOG = "debug";
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.rustdesk.fqdn}" = {
      listenAddresses = [infra.rustdesk.ip];
      extraConfig = ''import intraproxy 21114'';
    };
    rustdesk-server = {
      enable = true;
      relay = {
        enable = true;
        # extraArgs = [];
      };
      signal = {
        enable = true;
        relayHosts = ["10.20.6.190:21117"];
        # extraArgs = [];
      };
    };
  };
}
