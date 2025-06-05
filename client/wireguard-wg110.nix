{config, ...}: {
  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    wg-nix-pk-wg110 = {
      file = ../modules/resources/wg-nix-pk-wg110.age;
      owner = "systemd-network";
      group = "systemd-network";
    };
    wg-nix-psk = {
      file = ../modules/resources/wg-nix-psk.age;
      owner = "systemd-network";
      group = "systemd-network";
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
    networks.wg110 = {
      matchConfig.Name = "wg110";
      address = ["10.10.10.110/24"];
      dns = ["10.10.10.1"];
      gateway = ["10.10.10.1"];
      ntp = ["10.10.10.1"];
      DHCP = "no";
      linkConfig.RequiredForOnline = "no";
      networkConfig.IPv6AcceptRA = false;
    };
    netdevs = {
      "20-wg110" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg110";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = config.age.secrets.wg-nix-pk-wg110.path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            PublicKey = "ki9E8gNpETIa+ejcdfpy/Xvbge66m9ntkBVD5StOhmA=";
            PresharedKeyFile = config.age.secrets.wg-nix-psk.path;
            AllowedIPs = ["0.0.0.0/0"];
            Endpoint = "192.168.80.1:51820";
          }
        ];
      };
    };
  };
}
