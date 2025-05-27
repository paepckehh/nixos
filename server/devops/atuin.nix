{
  lib,
  config,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    atuin = {
      enable = true;
      host = "192.168.80.201";
      port = 8888;
      maxHistoryLength = 65536;
      openFirewall = true;
      openRegistration = true;
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."10-lan".addresses = [{Address = "${config.services.atuin.host}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${config.services.atuin.host} atuin atuin.${config.networking.domain}"; # ensure corresponding dns records
    firewall.allowedTCPPorts = [config.services.atuin.port];
  };
}
