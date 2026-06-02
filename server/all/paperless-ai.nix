# paperless-ai as docker container
# prep:
# mkdir -p /var/lib/paperless-ai/data && sudo chown -R 1000:1000 /var/lib/paperless-ai
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.paperless-ai.ip} ${infra.paperless-ai.hostname} ${infra.paperless-ai.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.paperless-ai.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.paperless-ai.fqdn}" = {
      listenAddresses = [infra.paperless-ai.ip];
      extraConfig = ''import intraproxy ${toString infra.paperless-ai.localbind.port.http}'';
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    docker.enable = true;
    oci-containers = {
      containers = {
        paperless-ai = {
          image = "clusterzx/paperless-ai:latest";
          ports = ["${infra.localhost.ip}:${toString infra.paperless-ai.localbind.port.http}:3000"];
          volumes = ["/var/lib/paperless-ai/data:/app/data"];
          user = "0:0";
          environment = {
            SET_SERVER_NAME = infra.paperless-ai.fqdn;
            PAPERLESS_API_URL = "${infra.paperless.fqdn}/api";
            PAPERLESS_API_TOKEN = "6a16400124dcd36bf57bcad61cc23b6661d648c0"; # ragenix
            PAPERLESS_USERNAME = "ai-batch";
            AI_PROVIDER = "ollama";
            OLLAMA_API_URL = "${infra.ai.worker.one}";
            OLLAMA_MODEL = "gpt-oss:latest";
            SCAN_INTERVAL = "*/30 * * * *";
            PROCESS_PREDEFINED_DOCUMENTS = "yes";
            TAGS = "ai-pending";
            ADD_AI_PROCESSED_TAG = "yes";
            AI_PROCESSED_TAG_NAME = "ai-processed";
            USE_EXISTING_DATA = "yes";
          };
        };
      };
    };
  };
}
