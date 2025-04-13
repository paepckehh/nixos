{
  config,
  pkgs,
  ...
}: {
  ##############
  # NETWORKING #
  ##############
  networking.firewall.allowedTCPPorts = [19532];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    journald = {
      enable = true;
      port = 19532;
      listen = "http"; # https
      output = "/var/log/journal/remote/";
      settings.Remote = {
        #   https mode:
        #   ServerKeyFile = "/etc/journal/remote.key";
        #   ServerCertificateFile = "/etc/journal/remote.pem";
        #   TrustedCertificateFile = "/etc/ssl/ca/trusted.pem;
        Seal = false;
        SplitMode = "host";
      };
    };
  };
}
