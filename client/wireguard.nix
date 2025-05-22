{config, ...}: {
  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    wg-nix-pk = {
      file = ../modules/resources/wg-nix-pk.age;
      owner = "root";
      group = "wheel";
    };
    wg-nix-psk = {
      file = ../modules/resources/wg-nix-psk.age;
      owner = "root";
      group = "wheel";
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall.checkReversePath = "loose"; # allow tunnel all traffic
    firewall.allowedUDPPorts = []; # map config.wireguard.wg0.listenPort or just 51820, only for reverse callback
  };

  ##################
  #-=# SYSTEMD  #=-#
  ##################
  systemd.network = {
    enable = true;
    networks.wg0 = {
      matchConfig.Name = "wg0";
      address = ["10.10.10.100/32"];
      DHCP = "no"; # XXX TODO check
      dns = ["10.10.10.1"];
      linkConfig.RequiredForOnline = "no";
      networkConfig.IPv4Forwarding = "yes"; # XXX TODO check
    };
    netdevs = {
      "20-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.wg-nix-pk.path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            PublicKey = "ADNsRa4aKJQKo6fYm9MnK2ORot5L6YMDTdd3iGgQp28=";
            PresharedKeyFile = config.age.secrets.wg-nix-psk.path;
            AllowedIPs = ["0.0.0.0/0"];
            Endpoint = "192.168.80.1:51820";
            # TODO: persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
