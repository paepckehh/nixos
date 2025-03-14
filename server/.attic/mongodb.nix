{
  config,
  pkgs,
  ...
}: {
  ####################
  #-=# SERVICES #=-#
  ####################
  services = {
    mongodb = {
      enable = true;
      bind_ip = "127.0.0.1";
      enableAuth = false;
      extraConfig = ''
        net:
           port: 27017
           bindIpAll: false
           ipv6: false
           unixDomainSocket:
              enabled: true
              filePermissions: 0700
              pathPrefix: /tmp
        storage:
           engine: wiredTiger
           directoryPerDB: true
           syncPeriodSecs: 60
           journal.commitIntervalMs: 500
        systemLog:
           timeStampFormat: iso8601-utc
           verbosity: 0
      '';
      dbpath = "/var/db/mongodb";
      initialScript = null;
      package = pkgs.mongodb;
      pidFile = "/run/mongodb.pid";
      quiet = false;
      replSetName = "";
      user = "mongodb";
    };
    prometheus.exporters.mongodb = {
      enable = false;
      collStats = [];
      collectAll = true;
      collector = [];
      extraFlags = [];
      firewallFilter = null;
      firewallRules = null;
      group = "mongodb-exporter";
      indexStats = [];
      listenAddress = "127.0.0.1";
      openFirewall = false;
      port = "9216";
      telemetryPath = "/metrics";
      uri = "mongodb://127.0.0.1:27017/db";
      user = "mongodb-exporter";
    };
  };
}
