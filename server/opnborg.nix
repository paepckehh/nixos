{
  config,
  pkgs,
  ...
}: {
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        opnborg = {
          image = "paepcke/opnborg:latest";
          ports = ["0.0.0.0:88898:6464"];
          environment = {
            OPN_TARGETS = "opn01.lan:8443,opn02.lan:8443";
            OPN_MASTER = "opn01.lan:8443";
            OPN_APIKEY = "+RIb6YWNdcDWMMM7W5ZYDkUvP4qx6e1r7e/Lg/Uh3aBH+veuWfKc7UvEELH/lajWtNxkOaOPjWR8uMcD";
            OPN_APISECRET = "8VbjM3HKKqQW2ozOe5PTicMXOBVi9jZTSPCGfGrHp8rW6m+TeTxHyZyAI1GjERbuzjmz6jK/usMCWR/p";
            OPN_TLSKEYPIN = "SG95BZoovDVQtclwEhINMitua05ZP9NfuI0mzzj0fXI=";
            OPN_PATH = "/tmp/opn";
            OPN_SLEEP = "60";
            OPN_DEBUG = "true";
            OPN_SYNC_PKG = "true";
            OPN_HTTPD_ENABLE = "true";
            OPN_HTTPD_SERVER = "0.0.0.0:6464";
            OPN_RSYSLOG_ENABLE = "true";
            OPN_RSYSLOG_SERVER = "192.168.122.1:5140";
            OPN_GRAFANA_WEBUI = "http://localhost:9090";
            OPN_GRAFANA_DASHBOARD_FREEBSD = "Kczn-jPZz/node-exporter-freebsd";
            OPN_GRAFANA_DASHBOARD_HAPROXY = "rEqu1u5ue/haproxy-2-full";
            OPN_WAZUH_WEBUI = "http://localhost:9292";
            OPN_PROMETHEUS_WEBUI = "http://localhost:9191";
          };
        };
      };
    };
  };
}
