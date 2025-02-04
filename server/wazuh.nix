{
  pkgs,
  lib,
  ...
}:
with lib; let
  ########################################
  # HOW TO SETUP WAZUH IN 6 SIMPLE STEPS #
  ########################################
  # 01 add wazuh.nix (this file)  via to your nix config     #  include via import [ ./wazuh.nix ];
  # 02 edit -> wazuh.nix, set: wazuh.autostart = false;      #  should be default, verify!
  # 02 sudo nixos-rebuild switch                             #  ...
  # 03 sh /etc/wazuh-init.sh                                 #  do not run as root! (asks for sudo creds)
  # 04 edit -> wazuh.nix, set: wazuh.autostart = true;       #  activate all 3 docker at next switch/boot
  # 05 sudo nixos-rebuild switch                             #  go! (restart services or reboot of needed)
  # ... get a coffee & before docker downloads are finished (> 8GB) [verify that we booted the latest nixos profile!]
  # ... open browser -> https://localhost:5601 (default)
  # ... backup /var/lib/wazuh on a regular basis (config, certs & database)
  # ... enjoy wazuh
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
        password = "start123!";
        port = "5601"; # your dashboard url -> https://localhost:port
      };
    };
    user = {
      api = {
        username = "wazuh-api";
        password = "start123!";
      };
      indexer = {
        username = "wazuh-indexer";
        password = "start123!";
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
      hostname = "wazuh.dashboard";
      imageName = "wazuh/wazuh-dashboard:${wazuh.version}";
      url = "https://${wazuh.dashboard.hostname}:${wazuh.webui.dashboard.urlPort}";
    };
    indexer = {
      hostname = "wazuh.indexer";
      imageName = "wazuh/wazuh-indexer:${wazuh.version}";
      url = "https://${wazuh.indexer.hostname}:9200";
    };
    manager = {
      hostname = "wazuh.manager";
      imageName = "wazuh/wazuh-manager:${wazuh.version}";
      url = "https://${wazuh.manager.hostname}";
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
    #################################
    # ENVIRONMENT SETUP INIT SCRIPT #
    #################################
    environment = {
      etc."wazuh-init.sh".text = lib.mkForce ''
        #!/bin/sh
        set -e
        sudo -v
        echo "[WAZUH.INIT] Trying to stock docker container, if already running ..."
        sudo systemctl stop docker-wazuh-indexer.service > /dev/null 2>&1
        sudo systemctl stop docker-wazuh-manager.service > /dev/null 2>&1
        sudo systemctl stop docker-wazuh-dashboard.service > /dev/null 2>&1
        TARGET="/var/lib/wazuh"
        if [ -x $TARGET ]; then
        	DTS="$(date '+%Y%m%d%H%M')"
        	echo "[WAZUH.INIT] Found pre-existing wazuh $TARGET, moving old config to $TARGET-$DTS"
        	sudo rm -rf $TARGET-$DTS > /dev/null 2>&1
        	sudo mv -f $TARGET $TARGET-$DTS
        fi
        sudo mkdir -p $TARGET && cd $TARGET
        nix-shell --packages git --run "sudo git clone --depth 1 --branch 4.10.2 https://github.com/wazuh/wazuh-docker wazuh-docker"
        cd wazuh-docker/single-node
        nix-shell --packages docker docker-compose --run "sudo docker-compose -f generate-indexer-certs.yml run --rm generator"
        sudo cp -af * ../..
        cd $TARGET && sudo rm -rf wazuh-docker
        exit 0
      '';
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
            ports = ["${wazuh.webui.dashboard.port}:5601"];
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
