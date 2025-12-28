{lib, ...}: {
  ##############
  # NETWORKING #
  ##############
  networking = {
    firewall.trustedInterfaces = ["enp1s0f4u2u4"];
    networkmanager.unmanaged = ["enp1s0f4u2u4"];
    usePredictableInterfaceNames = lib.mkForce true;
  };

  ############
  # SERVICES #
  ############
  services.atftpd = {
    enable = true;
    root = "/var/lib/tftp"; # create & place world readable recovery.bin tp_recovery.bin
    extraOptions = [
      "--bind-address 192.168.0.66"
      "--verbose=7"
    ];
  };

  ###########
  # SYSTEMD #
  ###########
  # networkctl
  # systemctl service-log-level systemd-networkd.service info
  # systemctl service-log-level systemd-networkd.service debug
  systemd = {
    services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug"; # warn, info, debug
    network = {
      enable = true;
      networks = {
        "usbtftp" = {
          enable = true;
          matchConfig.Name = "enp1s0f4u2u4"; # apple usb2 white
          addresses = [
            {Address = "192.168.0.66/24";}
          ];
          linkConfig = {
            ActivationPolicy = "always-up";
            RequiredForOnline = "no";
          };
        };
      };
    };
  };
}
