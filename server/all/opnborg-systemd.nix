{
  config,
  pkgs,
  lib,
  ...
}: {
  ####################
  #-=# ENVIROMENT #=-#
  ####################
  environment.systemPackages = [pkgs.unstable.opnborg];

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      opnborg = {
        createHome = true;
        description = "opnborg service account";
        uid = 6464;
        isSystemUser = true;
        group = "opnborg";
        home = "/var/lib/opnborg";
      };
    };
    groups."opnborg" = {
      name = "opnborg";
      members = ["opnborg"];
      gid = 6464;
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    services.opnborg = {
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      description = "OPNBorg Service";
      serviceConfig = {
        ExecStart = "${pkgs.unstable.opnborg}/bin/opnborg";
        KillMode = "process";
        Restart = "always";
        PreStart = "cd /var/lib/opnborg";
        User = "opnborg";
        StateDirectory = "opnborg";
        StateDirectoryMode = "0750";
        WorkingDirectory = "/var/lib/opnborg";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
      };
      environment = {
        OPN_TARGETS_STANDBY = "opn00.lan:8443#RACK-LAB-2ND-FLOOR";
        OPN_TARGETS_INTRANET = "opn01.lan:8443#RACK-PROD01,opn02.lan:8443#RACK-PROD02";
        OPN_TARGETS_EXTERNAL = "opn03.lan:8443#RACK-DMZ01-VODAFONE,opn04.lan:8443#RACK-DMZ02-TELEKOM";
        OPN_TARGETS_IMGURL_STANDBY = "https://paepcke.de/res/hot.png";
        OPN_TARGETS_IMGURL_INTRANET = "https://paepcke.de/res/int.png";
        OPN_TARGETS_IMGURL_EXTERNAL = "https://paepcke.de/res/ext.png";
        OPN_MASTER = "opn01.lan:8443";
        OPN_APIKEY = "+RIb6YWNdcDWMMM7W5ZYDkUvP4qx6e1r7e/Lg/Uh3aBH+veuWfKc7UvEELH/lajWtNxkOaOPjWR8uMcD";
        OPN_APISECRET = "8VbjM3HKKqQW2ozOe5PTicMXOBVi9jZTSPCGfGrHp8rW6m+TeTxHyZyAI1GjERbuzjmz6jK/usMCWR/p";
        OPN_TLSKEYPIN = "SG95BZoovDVQtclwEhINMitua05ZP9NfuI0mzzj0fXI=";
        OPN_PATH = "/tmp/opn";
        OPN_SLEEP = "60";
        OPN_DEBUG = "1";
        OPN_SYNC_PKG = "1";
        OPN_RSYSLOG_ENABLE = "1";
        OPN_RSYSLOG_SERVER = "192.168.122.1:5140";
        OPN_HTTPD_SERVER = "127.0.0.1:6464";
        OPN_GRAFANA_WEBUI = "http://localhost:9090";
        OPN_GRAFANA_DASHBOARD_FREEBSD = "Kczn-jPZz/node-exporter-freebsd";
        OPN_GRAFANA_DASHBOARD_HAPROXY = "rEqu1u5ue/haproxy-2-full";
        OPN_GRAFANA_DASHBOARD_UNIFI = "rEqu1u5ue/haproxy-2-full";
        OPN_WAZUH_WEBUI = "http://localhost:9292";
        OPN_PROMETHEUS_WEBUI = "http://localhost:9191";
        OPN_UNIFI_WEBUI = "https://localhost:8443#RACK-PROD03";
        OPN_UNIFI_VERSION = "8.5.6";
        OPN_UNIFI_BACKUP_USER = "admin";
        OPN_UNIFI_BACKUP_SECRET = "start";
        OPN_UNIFI_BACKUP_IMGURL = "https://paepcke.de/res/uni.png";
        OPN_UNIFI_EXPORT = "1";
        OPN_UNIFI_FORMAT = "csv";
        OPN_UNIFI_MONGODB_URI = "mongodb://127.0.0.1:27117";
        OPN_GITSRV = "1";
      };
    };
  };
}
