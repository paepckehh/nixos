{
  pkgs,
  lib,
  ...
}:
with lib; let
  #########################################
  # HOW TO SETUP WAZU IN UNDER 20 SECONDS #
  #########################################
  # set wazuh.autostart = false;
  # nix switch ...
  # TARGET="/var/lib/wazuh" && sudo mkdir -p $TARGET && cd $TARGET
  # sudo curl -OkL https://raw.githubusercontent.com/wazuh/wazuh-docker/refs/heads/master/single-node/generate-certs.yml
  # nix-shell --packages docker docker-compose --run "sudo docker-compose -f ./generate-certs.yml run --rm generator"
  # set wazuh.autostart = true;
  # nix switch ...
  #
  # ... quick, get a coffee & before docker downloads are finished (around 8GB!)
  # ... browser -> http://localhost:9090
  # ... backup /var/lib/wazuh on a regular basis
  # ... enjoy painfree wazuh setup
  #
  #######################
  # USER CONFIG SECTION #
  #######################
  wazuh = {
    enabled = true;
    autostart = true;
    version = "4.10.1";
    webui = {
      dashboard = {
        username = "wazuh";
        password = "start123!!";
        port = "9090"; # dashboard url -> http://localhost:port
      };
    };
    user = {
      api = {
        username = "wazuh-api";
        password = "start123!!";
      };
      indexer = {
        username = "wazuh-indexer";
        password = "start123!!";
      };
    };
  };

  #####################################
  # INTERNAL RESOURCES CONFIG SECTION #
  #####################################
  wazuh = {
    oci = {
      autostart = wazuh.autostart;
      confDir = "/var/lib/wazuh/config";
      backend = "docker";
      extraOptions = ["--network=host" "--ulimit" "nofile=655360:655360" "--ulimit" "memlock=-1:-1"];
    };
    dashboard = {
      hostname = "wazuh-dashboard.localnet";
      imageName = "wazuh/wazuh-dashboard:${wazuh.version}";
      url = "http://${wazuh.dashboard.hostname}:${wazuh.webui.dashboard.urlPort}";
    };
    indexer = {
      hostname = "wazuh-indexer.localnet";
      imageName = "wazuh/wazuh-indexer:${wazuh.version}";
      url = "http://${wazuh.indexer.hostname}:9200";
    };
    manager = {
      hostname = "wazuh-manager.localnet";
      imageName = "wazuh/wazuh-manager:${wazuh.version}";
      url = "http://${wazuh.manager.hostname}";
    };
  };
in
  mkIf wazuh.enabled {
    ##############
    # NETWORKING #
    ##############
    networking = {
      extraHosts = ''127.0.0.1 ${wazuh.manager.hostname} ${wazuh.indexer.hostname} ${wazuh.dashboard.hostname}'';
      firewall = {
        allowedTCPPorts = [1514 1515 55000 9200 5601];
        allowedUDPPorts = [514];
      };
    };

    ##################
    # VIRTUALISATION #
    ##################
    virtualisation = {
      oci-containers = {
        backend = wazuh.oci.backend;
        containers = {
          ###################
          # WAZUH-DASHBOARD #
          ###################
          wazuh-dashboard = {
            autoStart = wazuh.oci.autostart;
            extraOptions = wazuh.oci.extraOptions;
            hostname = wazuh.dashboard.hostname;
            image = wazuh.dashboard.imageName;
            ports = ["${wazuh.manager.urlPort}:5601"];
            environment = {
              API_USERNAME = "${wazuh.user.api.username}";
              API_PASSWORD = "${wazuh.user.api.password}";
              DASHBOARD_USERNAME = "${wazuh.webui.dashboard.username}";
              DASHBOARD_PASSWORD = "${wazuh.webui.dashboard.password}";
              INDEXER_URL = "${wazuh.indexer.url}";
              INDEXER_USERNAME = "${wazuh.user.indexer.username}";
              INDEXER_PASSWORD = "${wazuh.user.indexer.password}";
              WAZUH_API_URL = "${wazuh.manager.url}";
            };
            dependsOn = ["wazuh-indexer"];
            volumes = [
              "${wazuh.oci.confDir}/wazuh_indexer_ssl_certs/wazuh.dashboard.pem:/usr/share/wazuh-dashboard/certs/wazuh-dashboard.pem"
              "${wazuh.oci.confDir}/wazuh_indexer_ssl_certs/wazuh.dashboard-key.pem:/usr/share/wazuh-dashboard/certs/wazuh-dashboard-key.pem"
              "${wazuh.oci.confDir}/wazuh_indexer_ssl_certs/root-ca.pem:/usr/share/wazuh-dashboard/certs/root-ca.pem"
              "${wazuh.oci.confDir}/wazuh_dashboard/opensearch_dashboards.yml:/usr/share/wazuh-dashboard/config/opensearch_dashboards.yml"
              "${wazuh.oci.confDir}/wazuh_dashboard/wazuh.yml:/usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml"
              "wazuh-dashboard-config:/usr/share/wazuh-dashboard/data/wazuh/config"
              "wazuh-dashboard-custom:/usr/share/wazuh-dashboard/plugins/wazuh/public/assets/custom"
            ];
          };
          #################
          # WAZUH-INDEXER #
          #################
          wazuh-indexer = {
            autoStart = wazuh.oci.autostart;
            extraOptions = wazuh.oci.extraOptions;
            hostname = wazuh.indexer.hostname;
            image = wazuh.indexer.imageName;
            environment = {OPENSEARCH_JAVA_OPTS = "-Xms1g -Xmx1g";};
            ports = ["9200:9200"];
            volumes = [
              "wazuh-indexer-data:/var/lib/wazuh-indexer"
              "${wazuh.oci.confDir}/wazuh_indexer/wazuh.indexer.yml:/usr/share/wazuh-indexer/opensearch.yml"
              "${wazuh.oci.confDir}/wazuh_indexer/internal_users.yml:/usr/share/wazuh-indexer/opensearch-security/internal_users.yml"
              "${wazuh.oci.confDir}/wazuh_indexer_ssl_certs/root-ca.pem:/usr/share/wazuh-indexer/certs/root-ca.pem"
              "${wazuh.oci.confDir}/wazuh_indexer_ssl_certs/wazuh.indexer-key.pem:/usr/share/wazuh-indexer/certs/wazuh.indexer.key"
              "${wazuh.oci.confDir}/wazuh_indexer_ssl_certs/wazuh.indexer.pem:/usr/share/wazuh-indexer/certs/wazuh.indexer.pem"
              "${wazuh.oci.confDir}/wazuh_indexer_ssl_certs/admin.pem:/usr/share/wazuh-indexer/certs/admin.pem"
              "${wazuh.oci.confDir}/wazuh_indexer_ssl_certs/admin-key.pem:/usr/share/wazuh-indexer/certs/admin-key.pem"
            ];
          };
          #################
          # WAZUH-MANAGER #
          #################
          wazuh-manager = {
            autoStart = wazuh.oci.autostart;
            hostname = wazuh.manager.hostname;
            image = wazuh.manager.imageName;
            extraOptions = wazuh.oci.extraOptions;
            environment = {
              API_USERNAME = "${wazuh.user.api.username}";
              API_PASSWORD = "${wazuh.user.api.password}";
              INDEXER_URL = "${wazuh.indexer.url}";
              INDEXER_USERNAME = "${wazuh.user.indexer.username}";
              INDEXER_PASSWORD = "${wazuh.user.indexer.password}";
              FILEBEAT_SSL_VERIFICATION_MODE = "none"; # full
              SSL_CERTIFICATE_AUTHORITIES = "/etc/ssl/root-ca.pem";
              SSL_CERTIFICATE = "/etc/ssl/filebeat.pem";
              SSL_KEY = "/etc/ssl/filebeat.key";
            };
            ports = [
              "1514:1514"
              "1515:1515"
              "514:514/udp"
              "55000:55000"
            ];
            volumes = [
              "wazuh_api_configuration:/var/ossec/api/configuration"
              "wazuh_etc:/var/ossec/etc"
              "wazuh_logs:/var/ossec/logs"
              "wazuh_queue:/var/ossec/queue"
              "wazuh_var_multigroups:/var/ossec/var/multigroups"
              "wazuh_integrations:/var/ossec/integrations"
              "wazuh_active_response:/var/ossec/active-response/bin"
              "wazuh_agentless:/var/ossec/agentless"
              "wazuh_wodles:/var/ossec/wodles"
              "filebeat_etc:/etc/filebeat"
              "filebeat_var:/var/lib/filebeat"
              "${wazuh.oci.confDir}/wazuh_indexer_ssl_certs/root-ca-manager.pem:/etc/ssl/root-ca.pem"
              "${wazuh.oci.confDir}/wazuh_indexer_ssl_certs/wazuh.manager.pem:/etc/ssl/filebeat.pem"
              "${wazuh.oci.confDir}/wazuh_indexer_ssl_certs/wazuh.manager-key.pem:/etc/ssl/filebeat.key"
              "${wazuh.oci.confDir}/wazuh_cluster/wazuh_manager.conf:/wazuh-config-mount/etc/ossec.conf"
            ];
          };
        };
      };
    };
  }
