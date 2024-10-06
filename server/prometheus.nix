{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus = {
      enable = true;
      alertmanager.port = 9292;
      port = 9191;
      retentionTime = "365d";
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" # self
                "192.168.122.2:9100" # example opnsense node IP
                "192.168.122.3:9100" # example opnsense node IP
              ];
            }
          ];
        }
        {
          job_name = "haproxy";
          static_configs = [
            {
              targets = [
                "192.168.122.2:8404" # example opnsense node IP
                "192.168.122.3:8404" # example opnsense node IP
              ];
            }
          ];
        }
      ];
      exporters.node = {
        enable = true;
        port = 9100;
        enabledCollectors = [
          "logind"
          "systemd"
        ];
        disabledCollectors = [];
        openFirewall = true;
      };
    };
    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 9090;
          domain = "localhost";
        };
      };
    };
    promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 3031;
          grpc_listen_port = 0;
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
        clients = [
          {
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
          }
        ];
        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = "localhost";
              };
            };
            relabel_configs = [
              {
                source_labels = ["__journal__systemd_unit"];
                target_label = "unit";
              }
            ];
          }
        ];
      };
    };
    loki = {
      enable = true;
      configuration = {
        server.http_listen_port = 3030;
        auth_enabled = false;
        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = {
                store = "inmemory";
              };
              replication_factor = 1;
            };
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
        };
        schema_config = {
          configs = [
            {
              from = "2022-06-06";
              store = "boltdb-shipper";
              object_store = "filesystem";
              schema = "v11";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };
        storage_config = {
          boltdb_shipper = {
            active_index_directory = "/var/lib/loki/boltdb-shipper-active";
            cache_location = "/var/lib/loki/boltdb-shipper-cache";
            cache_ttl = "24h";
          };
          filesystem = {
            directory = "/var/lib/loki/chunks";
          };
        };
        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };
        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };
        compactor = {
          working_directory = "/var/lib/loki";
          compactor_ring = {
            kvstore = {
              store = "inmemory";
            };
          };
        };
      };
    };
  };
}
