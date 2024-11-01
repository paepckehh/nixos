{
  config,
  pkgs,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    wg-access-server = {
      enable = true;
      settings = {
        WG_ADMIN_PASSWORD = "start"; # webgui
        WG_CLIENT_ISOLATION = true;
        WG_CLIENTCONFIG_DNS_SERVERS = "192.168.83.3,192.168.83.2";
        WG_DNS_DOMAIN = "pvz.lan";
        # WG_DNS_ENABLED = false;
        # WG_DNS_UPSTREAM = "192.168.83.3,192.168.83.2";
        WG_ENABLE_INACTIVE_DEVICE_DELETION = false;
        WG_EXTERNAL_HOST = "wfh.pvz.digital";
        WG_INACTIVE_DEVICE_GRACE_PERIOD = "8760h";
        WG_IPV4_NAT_ENABLED = false;
        WG_IPV6_NAT_ENABLED = false;
        WG_LOG_LEVEL = "info";
        WG_PORT = "8443"; # webgui
        WG_VPN_ALLOWED_IPS = "192.168.0.0/8";
        WG_VPN_GATEWAY_INTERFACE = "eth0";
        WG_VPN_CIDRV4 = "192.168.80.0/24";
        WG_VPN_CIDRV6 = "0"; # disable
        WG_WIREGUARD_ENABLED = true;
        WG_WIREGUARD_PORT = "51820";
        WG_WIREGUARD_INTERFACE = "wg0";
        WG_WIREGUARD_PRIVATE_KEY = "aG4jqfU5Far8JXkZxoL4RrvC0Ic/KbZBNRDlnJyeBmo=";
      };
    };
  };
}
