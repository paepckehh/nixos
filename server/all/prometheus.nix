# prometheus monitoring alert management
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
  networking.extraHosts = "${infra.prometheus.ip} ${infra.prometheus.hostname} ${infra.prometheus.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    network.networks."${infra.namespace.admin}".addresses = [{Address = "${infra.prometheus.ip}/32";}];
    tmpfiles.rules = ["d ${infra.prometheus.storage} 0700 prometheus prometheus"];
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.prometheus = {};
    users = {
      prometheus = {
        group = "prometheus";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  # systemd.services = {
  #  prometheus = {
  #    after = ["network-online.target"];
  #    wants = ["network-online.target"];
  #    wantedBy = ["multi-user.target"];
  #  };
  #  prometheus-node-exporter = {
  #    after = ["network-online.target"];
  #    wants = ["network-online.target"];
  #    wantedBy = ["multi-user.target"];
  #  };
  #  prometheus-smartctl-exporter = {
  #    after = ["network-online.target"];
  #    wants = ["network-online.target"];
  #    wantedBy = ["multi-user.target"];
  #  };
  # };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.prometheus.fqdn}" = {
      listenAddresses = [infra.prometheus.ip];
      extraConfig = ''import adminproxy ${toString infra.prometheus.localbind.port.http}'';
    };
    prometheus = {
      enable = true;
      listenAddress = infra.localhost.ip;
      port = infra.prometheus.localbind.port.http;
      alertmanager.port = infra.prometheus.localbind.port.alertmanager;
      retentionTime = infra.prometheus.db.retenetion;
      webExternalUrl = infra.prometheus.url;
      globalConfig = {
        scrape_interval = "15m";
        scrape_timeout = "30s";
      };
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{targets = infra.prometheus.exporter.node.targets;}];
        }
        {
          job_name = "smartctl";
          static_configs = [{targets = infra.prometheus.exporter.smartctl.targets;}];
        }
      ];
      exporters = {
        node = {
          enable = true;
          port = infra.prometheus.exporter.node.port;
          enabledCollectors = ["logind" "systemd" "zfs"];
          disabledCollectors = [];
        };
        smartctl = {
          enable = true;
          port = infra.prometheus.exporter.smartctl.port;
          devices = infra.prometheus.exporter.smartctl.devices;
        };
      };
    };
  };
}
