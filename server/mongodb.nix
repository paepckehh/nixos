{
  config,
  pkgs,
  ...
}: let
  #################
  #-=# mongodb #=-#
  #################
  mongodb = {
    listenAddress = "127.0.0.1";
    monitoring = {
      enable = true;
      listenAddress = mongodb.listenAddress;
    };
  };
in {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [mongosh];

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers = {
        mongo-express = {
          image = "mongo-express";
          ports = ["${mongodb.monitoring.listenAddress}:8081:8081"];
          extraOptions = ["--network=host"];
        };
      };
    };
  };

  ####################
  #-=# SERVICES #=-#
  ####################
  services = {
    mongodb = {
      enable = true;
      bind_ip = mongodb.listenAddress;
      enableAuth = false;
      extraConfig = ''
        net:
           port: 27017
           bindIpAll: false
           ipv6: false
           unixDomainSocket:
              enabled: true
              filePermissions: 0770
              pathPrefix: /tmp
        storage:
           engine: wiredTiger
           directoryPerDB: true
           syncPeriodSecs: 120
           journal.commitIntervalMs: 2500
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
    prometheus = {
      enable = mongodb.monitoring.enable;
      listenAddress = mongodb.monitoring.listenAddress;
      port = 9191;
      retentionTime = "90d";
      alertmanager.port = 9292;
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{targets = ["${config.services.prometheus.exporters.node.listenAddress}:${toString config.services.prometheus.exporters.node.port}"];}];
        }
        {
          job_name = "smartctl";
          static_configs = [{targets = ["${config.services.prometheus.exporters.smartctl.listenAddress}:${toString config.services.prometheus.exporters.smartctl.port}"];}];
        }
        {
          job_name = "mongodb";
          static_configs = [{targets = ["${config.services.prometheus.exporters.mongodb.listenAddress}:${toString config.services.prometheus.exporters.mongodb.port}"];}];
        }
      ];
      exporters = {
        node = {
          enable = config.services.prometheus.enable;
          enabledCollectors = ["logind" "systemd"];
          disabledCollectors = [];
          listenAddress = mongodb.monitoring.listenAddress;
          port = 9100;
        };
        smartctl = {
          enable = config.services.prometheus.enable;
          devices = ["/dev/sda"]; # /dev/nvme0
          listenAddress = mongodb.monitoring.listenAddress;
          port = 9633;
        };
        mongodb = {
          enable = config.services.prometheus.enable;
          collStats = [];
          collectAll = true;
          collector = [];
          extraFlags = [];
          firewallFilter = null;
          firewallRules = null;
          group = "mongodb-exporter";
          indexStats = [];
          openFirewall = false;
          telemetryPath = "/metrics";
          uri = "mongodb://${config.services.prometheus.exporters.mongodb.listenAddress}:27017/db";
          user = "mongodb-exporter";
          listenAddress = mongodb.monitoring.listenAddress;
          port = 9216;
        };
      };
    };
    grafana = {
      enable = config.services.prometheus.enable;
      provision.enable = config.services.grafana.enable;
      settings.server = {
        http_addr = mongodb.monitoring.listenAddress;
        http_port = 9090;
        domain = "localhost";
      };
    };
  };
}
