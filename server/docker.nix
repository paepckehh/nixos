{
  config,
  pkgs,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
     ./cockpit.nix
  ];
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      containers = {
        whoogle = {
          image = "benbusby/whoogle-search:latest";
          ports = ["0.0.0.0:8080:8080"];
          environment = {
            EXPOSE_PORT = "8080";
            WHOOGLE_MINIMAL = "1";
            WHOOGLE_RESULTS_PER_PAGE = "50";
            WHOOGLE_CONFIG_LANGUAGE = "en";
            WHOOGLE_CONFIG_SEARCH_LANGUAGE = "en";
            WHOOGLE_CONFIG_SAFE = "1";
            WHOOGLE_CONFIG_URL = "http://localhost:8080";
          };
        };
        speed = {
          image = "openspeedtest/latest:latest";
          ports = ["0.0.0.0:8181:8080"];
          environment = {
            HTTP_PORT = "8080";
            HTTPS_PORT = "8443";
            CHANGE_CONTAINER_PORTS = "1";
            SET_SERVER_NAME = "speed.pvz.lan";
          };
        };
        burn = {
          image = "jhaals/yopass:latest";
          ports = ["0.0.0.0:8282:1337"];
        };
        grist = {
          image = "gristlabs/grist";
          ports = ["0.0.0.0:8383:80"];
        };
        opnborg = {
          image = "paepckehh/opnborg";
          ports = ["0.0.0.0:88898:6464"];
          environment = {
            OPN_TARGETS="opn01.lan:8443,opn02.lan:8443";
            OPN_MASTER="opn01.lan:8443";
            OPN_APIKEY="+RIb6YWNdcDWMMM7W5ZYDkUvP4qx6e1r7e/Lg/Uh3aBH+veuWfKc7UvEELH/lajWtNxkOaOPjWR8uMcD";
            OPN_APISECRET="8VbjM3HKKqQW2ozOe5PTicMXOBVi9jZTSPCGfGrHp8rW6m+TeTxHyZyAI1GjERbuzjmz6jK/usMCWR/p";
            OPN_TLSKEYPIN="SG95BZoovDVQtclwEhINMitua05ZP9NfuI0mzzj0fXI=";
            OPN_PATH="/tmp/opn";
            OPN_SLEEP="60";
            OPN_DEBUG="true";
            OPN_SYNC_PKG="true";
            OPN_HTTPD_ENABLE="true";
            OPN_HTTPD_SERVER="0.0.0.0:6464";
            OPN_RSYSLOG_ENABLE="true";
            OPN_RSYSLOG_SERVER="192.168.122.1:5140";
            OPN_GRAFANA_WEBUI="http://localhost:9090";
            OPN_GRAFANA_DASHBOARD_FREEBSD="Kczn-jPZz/node-exporter-freebsd";
            OPN_GRAFANA_DASHBOARD_HAPROXY="rEqu1u5ue/haproxy-2-full";
            OPN_WAZUH_WEBUI="http://localhost:9292";
            OPN_PROMETHEUS_WEBUI="http://localhost:9191";
          }
        };
        # nocdb = {
        #  image = "nocdb/nocdb";
        #  ports = ["0.0.0.0:8484:80"];
        # };
        #spot = {
        #  image = "yooooomi/your_spotify_server";
        #  ports = ["0.0.0.0:8585:8080"];
        #};
      };
    };
  };
}
