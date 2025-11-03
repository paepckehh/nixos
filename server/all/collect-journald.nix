{
  ##############
  # NETWORKING #
  ##############
  networking.firewall.allowedTCPPorts = [19532];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    journald.remote = {
      enable = true;
      port = 19532;
      listen = "http"; # https
      output = "/var/log/journal/remote/";
      settings.Remote = {
        Seal = true;
        SplitMode = "host";
      };
    };
  };
}
