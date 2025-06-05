{lib, ...}:
with lib; let
  ########################################
  # HOW TO SETUP WAZUH IN 6 SIMPLE STEPS #
  ########################################
  # [1] add wazuh.nix (this file) into your nix config        #  include via import [ ./wazuh.nix ];
  # [2] sudo nixos-rebuild switch                             #  ...
  # [3] sh /etc/wazuh-init.sh init                            #  do not run as root! (asks for sudo creds)
  # [4] edit -> wazuh.nix, set: wazuh.autostart = true;       #  activate all 3 docker at next switch/boot
  # [5] sudo nixos-rebuild switch                             #  go, start docker download, >8GB, restart services
  #
  # HINTS:
  # ... open browser -> https://localhost:5601 (default login user, password = kibanaserver) - change passwords now!
  # ... always verify that we booted the latest correct nixos profile! (nix switch is not always correct)
  # ... username and passwords (initial-only!) are hardwired in several places, change them within the running app, not here!
  # ... change default passwords before going into prod! [https://documentation.wazuh.com/current/user-manual/user-administration/password-management.html]
  # ... siem solutions like wazuh are high value and very error prone malware (automatic-scan) targets itself, they add large attac surface!
  # ... do not expose the sever backend and server(eg. domain controller collectors) to [windows/internet] connected client networks!
  # ... backup /var/lib/wazuh on a regular basis (config, certs & database), enjoy!
  #
  #######################
  # USER CONFIG SECTION #
  #######################
  wazuh = {
    enabled = true;
    autostart = true;
    version = "4.12.0";
    webui = {
      dashboard = {
        port = 5601;
      };
    };
    indexer = {
      port = 9200;
    };
  };

  #####################################################
  # INTERNAL RESOURCES DOCKER CONFIG DEFAULTS SECTION #
  #####################################################
  # Do not modify init defaults, change later in webgui
  # Initial values are hardwired in upstream dockerfile
  wazuh = {
    webui = {
      dashboard = {
        user = {
          username = "kibanaserver";
          password = "kibanaserver";
        };
      };
    };
    api = {
      user = {
        username = "wazuh-wui";
        password = "MyS3cr37P450r.*-";
      };
    };
    indexer = {
      user = {
        username = "admin";
        password = "SecretPassword";
      };
    };
  };
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
      url = "https://${wazuh.dashboard.hostname}:${toString wazuh.webui.dashboard.port}";
    };
    indexer = {
      hostname = "wazuh.indexer";
      imageName = "wazuh/wazuh-indexer:${wazuh.version}";
      url = "https://${wazuh.indexer.hostname}:${toString wazuh.indexer.port}";
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
        allowedTCPPorts = [1514 1515 55000 wazuh.indexer.port wazuh.webui.dashboard.port];
        allowedUDPPorts = [514];
      };
    };
    ###############
    #-=# USERS #=-#
    ###############
    users = {
      users."wazuh-indexer" = {
        hashedPassword = null; # disable interaive login
        description = "wazu service account";
        uid = 1000; # fixed via dockerfile upstream, do not change
        group = "wazuh-indexer";
        createHome = false;
        isNormalUser = false;
        isSystemUser = true;
        extraGroups = ["wazuh-indexer"];
      };
      groups."wazuh-indexer" = {
        gid = 1000; # fixed via dockerfile upstream, do not change
        members = ["wazuh-indexer"];
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
            ports = ["${toString wazuh.webui.dashboard.port}:5601"];
            environment = {
              API_USERNAME = "${wazuh.api.user.username}";
              API_PASSWORD = "${wazuh.api.user.password}";
              DASHBOARD_USERNAME = "${wazuh.webui.dashboard.user.username}";
              DASHBOARD_PASSWORD = "${wazuh.webui.dashboard.user.password}";
              INDEXER_URL = "${wazuh.indexer.url}";
              INDEXER_USERNAME = "${wazuh.indexer.user.username}";
              INDEXER_PASSWORD = "${wazuh.indexer.user.password}";
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
              API_USERNAME = "${wazuh.api.user.username}";
              API_PASSWORD = "${wazuh.api.user.password}";
              INDEXER_URL = "${wazuh.indexer.url}";
              INDEXER_USERNAME = "${wazuh.indexer.user.username}";
              INDEXER_PASSWORD = "${wazuh.indexer.user.password}";
              FILEBEAT_SSL_VERIFICATION_MODE = "full"; # full|none
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
    #################################
    # ENVIRONMENT SETUP INIT SCRIPT #
    #################################
    environment = {
      etc."wazuh-init.sh".text = lib.mkForce ''
        #!/bin/sh
        sudo -v
        wazuh_stop() {
        	echo "[WAZUH.INIT] Trying to stop all wazuh docker container ..."
        	sudo systemctl stop docker-wazuh-indexer.service >/dev/null 2>&1
        	sudo systemctl stop docker-wazuh-manager.service >/dev/null 2>&1
                sudo systemctl stop docker-wazuh-dashboard.service >/dev/null 2>&1
                sync
        }
        wazuh_restart() {
        	echo "[WAZUH.INIT] Trying to restart all wazuh docker container ..."
        	sudo systemctl restart docker-wazuh-indexer.service >/dev/null 2>&1
        	sudo systemctl restart docker-wazuh-manager.service >/dev/null 2>&1
                sudo systemctl restart docker-wazuh-dashboard.service >/dev/null 2>&1
                sync
        }
        wazuh_wipe() {
        	echo "[WAZUH.INIT] Trying to clean all wazuh config and data files ..."
                wazuh_stop
                sudo rm -rf /var/lib/wazuh
        }
        wazuh_init() {
        	wazuh_stop
        	TARGET="/var/lib/wazuh"
        	if [ -x $TARGET ]; then
        		DTS="$(date '+%Y%m%d%H%M')"
        		echo "[WAZUH.INIT] Found pre-existing wazuh $TARGET, moving old config to $TARGET-$DTS"
        		sudo rm -rf $TARGET-$DTS >/dev/null 2>&1
        		sudo mv -f $TARGET $TARGET-$DTS
        	fi
        	sudo mkdir -p $TARGET && cd $TARGET
        	nix-shell --packages git --run "sudo git clone --depth 1 --branch 4.12.1 https://github.com/wazuh/wazuh-docker wazuh-docker"
        	cd wazuh-docker/single-node
        	nix-shell --packages docker docker-compose --run "sudo docker-compose -f generate-indexer-certs.yml run --rm generator"
        	sudo cp -af * ../..
        	cd $TARGET && sudo rm -rf wazuh-docker
                sudo chown -R 1000:1000 /var/lib/wazuh
                wazuh_restart
                sudo chown -R 1000:1000 /var/lib/wazuh
                wazuh_restart
        	echo "[WAZUH.INIT] Setup Finished. Docker Container Autoupdate will perform in Background now."
        	echo "[WAZUH.INIT] Setup Finished. When finished visit https://localhost:5601 (Dashboard)."
        }
        case $1 in
        init) wazuh_init ;;
        restart) wazuh_restart ;;
        stop) wazuh_stop ;;
        wipe) wazuh_wipe ;;
        *) echo "[WAZU.INIT] No action specified, please specify [init|restart|stop|wipe]!";;
        esac
        exit 0
      '';
    };
  }
