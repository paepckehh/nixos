{
  pkgs,
  lib,
  config,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        devops = {
          ip = "192.168.80.215";
          hostname = "devops";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7013;
          };
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [
    {Address = "${infra.lan.services.devops.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.devops.ip} ${infra.lan.services.devops.hostname} ${infra.lan.services.devops.hostname}.${infra.lan.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.devops.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    olivetin = {
      enable = true;
      user = "root";
      group = "wheel";
      path = with pkgs; [bash];
      settings = {
        pageTitle = "DevOPs - NixOPs";
        showFooter = true;
        showNewVersions = false;
        showNavigation = true;
        logLevel = "INFO";
        authRequireGuestsToLogin = false;
        authLocalUsers = {
          enabled = true;
          users = {
            username = "admin";
            usergroup = "admins";
            password = "$argon2id$v=19$m=65536,t=4,p=12$Aio0SwqUuf7d6oprEO8CIA$aWKTEQsyqyksLlAS4hewV5ijcsUTi1sf4ncPvS40do8"; # start
          };
        };
        defaultPermissions = {
          view = true;
          exec = false;
        };
        accessControlLists = [
          {
            name = "admins";
            matchUsergroups = ["admins"];
            addToEveryAction = true;
            permissions = {
              view = true;
              exec = true;
              logs = true;
            };
          }
        ];
        actions = [
          {
            title = "Reboot Local System";
            shell = "reboot";
            icon = "smile";
          }
          {
            title = "Poweroff Local System";
            shell = "poweroff";
            icon = "&#128064;";
            arguments = {
              title = "Are you sure?! To Restart you will need local assistance!";
              type = "confirmation";
            };
          }
          {
            title = "Update Local System";
            shell = "/run/current-system/sw/bin/make -C /etc/nixos update switch";
            icon = "&#x2699;";
            timeout = 720;
            popupOnStart = "execution-dialog";
            maxConcurrent = 1;
          }
          {
            title = "Update Local System and Reboot";
            shell = "/run/current-system/sw/bin/make -C /etc/nixos update boot && reboot";
            icon = "&#x2699;";
            timeout = 720;
            popupOnStart = "execution-dialog";
            maxConcurrent = 1;
          }
          {
            title = "Flush DNS Cache";
            shell = "systemctl restart systemd-resolved.service";
            icon = "&#128260;";
            acls = ["admins" "guests"];
          }
          {
            title = "Reboot node moode.lan [via ssh]";
            shell = "ssh -t -p 6623 me@moode.lan 'reboot'";
            icon = "&#x1F6E0";
          }
        ];
        dashboards = {
          title = "Admin Dashboard";
          contents.title = "Restart";
        };
        ListenAddressSingleHTTPFrontend = "${infra.lan.services.devops.localbind.ip}:${toString infra.lan.services.devops.localbind.ports.tcp}";
      };
    };
    caddy = {
      enable = true;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      virtualHosts."devops.${infra.lan.domain}".extraConfig = ''
        bind ${infra.lan.services.devops.ip}
        reverse_proxy ${infra.lan.services.devops.localbind.ip}:${toString infra.lan.services.devops.localbind.ports.tcp}
        tls acme@pki.lan {
              ca_root /etc/ca.crt
              ca https://pki.lan/acme/acme/directory
        }
        @not_intranet {
          not remote_ip ${infra.lan.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/access/proxy-read.log
        }'';
    };
  };
}
