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
    firewall.allowedUDPPorts = []; # map config.wireguard.wg0.listenPort or just 51820, only for reverse callback
    wireguard.interfaces = {
      wg0 = {
        ips = ["10.10.10.100/32"];
        listenPort = 51820;
        privateKeyFile = config.age.secrets.wg-nix-pk.path;
        peers = [
          {
            endpoint = "192.168.80.1:51820";
            publicKey = "ADNsRa4aKJQKo6fYm9MnK2ORot5L6YMDTdd3iGgQp28=";
            allowedIPs = ["0.0.0.0/0"]; # just dump anything there
            presharedKeyFile = config.age.secrets.wg-nix-psk.path;
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
