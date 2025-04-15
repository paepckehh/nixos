{
  ##############
  # NETWORKING #
  ##############
  networking.firewall.allowedTCPPorts = [8989];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://notify.paepcke.de";
        listen-http = ":8989";
      };
    };
  };
}
