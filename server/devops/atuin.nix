{config}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    atuin = {
      enable = true;
      host = "192.168.80.240";
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
    extraHosts = "${config.services.atuin.host} atuin atuin.lan"; # ensure corresponding dns records
    firewall.allowedTCPPorts = [config.serices.atuin.port];
  };
}
