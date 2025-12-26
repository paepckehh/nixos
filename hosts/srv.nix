{lib, ...}: {
  ##############
  # NETWORKING #
  ##############
  networking = {
    usePredictableInterfaceNames = lib.mkForce true;
    networkmanager = {
      enable = true;
      unmanaged = ["enp1s0f4u2u1"];
    };
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
      wait-online = {
        enable = true;
        ignoredInterfaces = ["lo*" "wl*"];
      };
      networks = {
        "legacy" = {
          enable = true;
          matchConfig.Name = "enp1s0f4u2u1";
          DHCP = "ipv4";
          # addresses = [{Address = "192.168.80.100/24";}];
          # ntp = ["192.168.80.1"];
          # dns = ["192.168.80.1"];
          # gateway = ["192.168.80.1"];
        };
        "cloud" = {
          enable = true;
          domains = ["corp" "home.corp" "home.corp" "admin.corp"];
          dns = ["10.50.6.53"];
          matchConfig.Name = "lo*";
          linkConfig.RequiredForOnline = "carrier"; # no, yes, routable, carrier
          addresses = [
            #### admin
            {Address = "10.50.0.86/32";} # ldap (iam)
            {Address = "10.50.0.87/32";} # sso
            {Address = "10.50.0.100/23";} # host native network access /23
            {Address = "10.50.0.108/32";} # pki
            {Address = "10.50.0.110/32";} # monitoring
            {Address = "10.50.0.111/32";} # status
            {Address = "10.50.0.151/32";} # webacme
            {Address = "10.50.0.152/32";} # webpki
            {Address = "10.50.0.153/32";} # webmtls
            #### user
            {Address = "10.50.6.25/32";} # smtp
            {Address = "10.50.6.26/32";} # autoconfig
            {Address = "10.50.6.27/32";} # webmail
            {Address = "10.50.6.53/32";} # dns
            {Address = "10.50.6.86/32";} # iam
            {Address = "10.50.6.87/32";} # sso
            {Address = "10.50.6.100/23";} # host native network access /23
            {Address = "10.50.6.110/32";} # monitoring
            {Address = "10.50.6.111/32";} # status
            {Address = "10.50.6.117/32";} # cloud
            {Address = "10.50.6.119/32";} # search
            {Address = "10.50.6.126/32";} # ldap iam
            {Address = "10.50.6.125/32";} # paperless
            {Address = "10.50.6.135/32";} # portal start
            {Address = "10.50.6.141/32";} # res
            {Address = "10.50.6.143/32";} # imap
            {Address = "10.50.6.154/32";} # translate-lama
            {Address = "10.50.6.154/32";} # test
            {Address = "10.50.6.156/32";} # grist
            {Address = "10.50.6.157/32";} # meshtastic-web
            {Address = "10.50.6.158/32";} # glance
            {Address = "10.50.6.159/32";} # immich
            {Address = "10.50.6.160/32";} # ente
            {Address = "10.50.6.161/32";} # miniflux
            {Address = "10.50.6.162/32";} # navidrome
            {Address = "10.50.6.163/32";} # chef
            {Address = "10.50.6.164/32";} # onlyoffice
            {Address = "10.50.6.165/32";} #
            {Address = "10.50.6.166/32";} #
          ];
          # networkConfig = [
          #          IPv4Forwarding = false;
          #          IPv6Forwarding = false;
          #          DNSDefaultRoute = true;
          # ];
          # matchConfig.Path = "pci-0000:09:00.0";
          # routes = [
          #  {
          #    Gateway = "192.168.0.1";
          #    GatewayOnLink = true;
          #  }
          # ];
        };
      };
    };
  };
}
