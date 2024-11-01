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
        # adminPassword = "start";
        port = "8443";
        loglevel = "info";
        externalHost = "wfh.pvz.digital";
        wireguard = {
          enabled = true;
          interface = "wg0";
          port = "51820";
          # privateKey = "aG4jqfU5Far8JXkZxoL4RrvC0Ic/KbZBNRDlnJyeBmo=";
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
          enabled = false;
          domain = "pvz.lan";
          upstream = "192.168.83.3,192.168.83.2";
        };
        clientConfig = {
          dnsSearchDomain = "pvz.lan";
          dnsServer = "192.168.83.3,192.168.83.2";
        };
      };
    };
  };
}
