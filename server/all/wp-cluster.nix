{
  lib,
  infra,
  ...
}: let
  getIpSuffix = name:
    toString (
      100
      + lib.lists.findFirstIndex (
        x: x == name
      ) (throw "wp-cluster: unknown instance ${name}")
      infra.wp-cluster.wpInstances
    );
in {
  services.caddy.virtualHosts =
    lib.genAttrs (map (name: "${name}.${infra.wp-cluster.valDomain}") infra.wp-cluster.wpInstances) (
      domain: let
        name = lib.head (lib.strings.splitString "." domain);
      in {
        listenAddresses = [infra.wp-cluster.ip];
        # 'import intra' = caddy config is defined upstream role server already, assume its ok!
        extraConfig = ''
          import intra
          root * /var/lib/caddy/${name}.${infra.wp-cluster.valDomain}
        '';
      }
    )
    // lib.genAttrs (map (name: "${name}.${infra.wp-cluster.baseDomain}") infra.wp-cluster.wpInstances)
    (
      domain: let
        name = lib.head (lib.strings.splitString "." domain);
        ipSuffix = getIpSuffix name;
      in {
        listenAddresses = [infra.wp-cluster.ip];
        # 'import intra' = caddy config is defined upstream role server already, assume its ok!
        extraConfig = ''
          import intra
          reverse_proxy ${infra.wp-cluster.baseIP}.${ipSuffix}:80
          request_body {
              max_size 128mb
          }
        '';
      }
    );
  systemd = {
    network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.wp-cluster.ip}/32";}];
    tmpfiles.rules =
      map (
        name: "d /var/lib/caddy/${name}.${infra.wp-cluster.valDomain} 0755 caddy caddy -"
      )
      infra.wp-cluster.wpInstances;
  };
  containers = lib.genAttrs infra.wp-cluster.wpInstances (name: {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "${infra.wp-cluster.baseIP}.1";
    localAddress = "${infra.wp-cluster.baseIP}.${getIpSuffix name}";
    config = {pkgs, ...}: {
      system.stateVersion = "26.11";
      networking.firewall.allowedTCPPorts = [80];
      services.phpfpm.pools."${name}" = {
        user = "nginx";
        group = "nginx";
        settings = {
          "listen" = "/run/phpfpm/phpfpm.sock";
          "listen.owner" = "nginx";
          "listen.group" = "nginx";
          "pm" = "dynamic";
          "pm.max_children" = 32; # High performance allocation for Elementor
          "pm.start_servers" = 4;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 8;
          "pm.max_requests" = 1000;
          "php_admin_value[upload_max_filesize]" = "128M";
          "php_admin_value[post_max_size]" = "128M";
          "php_admin_value[memory_limit]" = "512M"; # Essential for Elementor + Rank Math
          "php_admin_value[max_execution_time]" = "300";
          "php_admin_value[opcache.memory_consumption]" = "256";
          "php_admin_value[opcache.max_accelerated_files]" = "30000";
          "php_admin_value[opcache.validate_timestamps]" = "1";
        };
      };
      services.nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        virtualHosts."default" = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 80;
            }
          ];
          root = "/var/www/${name}";
          extraConfig = ''
            index index.php;
            client_max_body_size 128M;
            location ~* /(?:uploads|files)/.*\.php$ { deny all; }
            location ~ /\.(?!well-known).* { deny all; }
            location ~* \.(js|css|png|jpg|jpeg|gif|ico|woff|woff2|svg)$ {
                expires max;
                log_not_found off;
                access_log off;
            }
            location / {
                try_files $uri $uri/ /index.php?$args;
            }
            location ~ \.php$ {
                include ${pkgs.nginx}/conf/fastcgi_params;
                fastcgi_intercept_errors on;
                fastcgi_pass unix:/run/phpfpm/phpfpm.sock;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_read_timeout 300;
            }
          '';
        };
      };
      services.mysql = {
        enable = true;
        package = pkgs.mariadb;
        settings.mysqld = {
          innodb_buffer_pool_size = "256M";
          innodb_log_file_size = "64M";
          innodb_flush_log_at_trx_commit = 2;
        };
        ensureDatabases = [name];
        ensureUsers = [
          {
            name = name;
            ensurePermissions = {
              "${name}.*" = "ALL PRIVILEGES";
            };
          }
        ];
      };
      systemd.tmpfiles.rules = ["d /var/www/${name} 0755 nginx nginx -"];
    };
  });
}
