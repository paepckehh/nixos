# endlessh ssh tarpit minimal ids
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../siteconfig/config.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.firewall.allowedTCPPorts = [22];

  ##################
  #-=# SERVICES #=-#
  ##################
  services.endlessh = {
    enable = true;
    port = 22;
    extraOptions = ["-4" "-s" "-v" "-d 4500"];
  };
}
