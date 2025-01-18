{config, ...}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    wg-quick.interfaces = {
      "wg-pvz-adm" = {
        address = ["10.0.8.201/24"];
        dns = ["10.0.8.2" "10.0.8.3"];
        privateKey = "[INVALID-PRIVATE-KEY-FROM-GENERIC-WG-NIX-CONFIG-FILE-PLEASE-CHECK-YOUR-NIX-CONF]"; # XXX
        peers = [
          {
            publicKey = "AAA..."; # XXX
            allowedIPs = ["10.0.8.0/24"];
            endpoint = "AA66-Z22P-Y22Y-KQ59.pvz.digital:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
