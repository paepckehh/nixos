{
  config,
  lib,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.nftables.enable = lib.mkForce false;

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    wg-access-server = {
      enable = true;
      secretsFile = "/etc/nixos/server/resources/wg-access-server-secrets.yaml";
      settings = {
        adminUsername = "admin";
        loglevel = "info";
        externalHost = "wfh.pvz.digital";
        wireguard = {
          enabled = true;
          interface = "wg0";
        };
        vpn = {
          allowedIPs = ["192.168.80.0/24"];
          cidr = "192.168.80.0/24";
          cidrv6 = "0";
          nat44 = false;
          nat66 = false;
          clientIsolation = true;
          gatewayInterface = "eth0";
        };
        dns = {
          enabled = true;
          domain = "pvz.lan";
          upstream = ["192.168.83.3" "192.168.83.2"];
        };
        clientConfig = {
          dnsSearchDomain = "pvz.lan";
          dnsServer = ["192.168.83.3" "192.168.83.2"];
        };
      };
    };
  };
}
