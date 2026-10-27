# infra is define upstream, here some example:
# infra.wp-cluster = {
#      id = 60;
#      app = "wordpress";
#      name = "wp-cluster";
#      hostname = infra.wp-cluster.name;
#      domain = infra.domain.user;
#      fqdn = "${infra.wp-cluster.hostname}.${infra.wp-cluster.domain}";
#      ip = "${infra.net.user}.${toString infra.wp-cluster.id}";
#      url = "https://${infra.wp-cluster.fqdn}";
#      baseIP = "10.250.${toString infra.wp-cluster.id}";
#      baseDomain = "de.dbt.corp";
#      valDomain = "de.val.dbt.corp";
#      wpInstances = [ "debitor" "coin4" "abilita" "parkeule" ];
# };
{
  lib,
  infra,
  ...
}: let
  # The list order of infra.wp-cluster.wpInstances fixes the addressing:
  # container localAddress = baseIP.(200+index), host side of the veth =
  # baseIP.(100+index), and the prod caddy vhost reverse proxies to the
  # container address.
  instanceIndexOf = name:
    lib.lists.findFirstIndex (
      x: x == name
    ) (throw "wp-cluster: unknown instance ${name}")
    infra.wp-cluster.wpInstances;
  hostIp = name: "${infra.wp-cluster.baseIP}.${toString (100 + instanceIndexOf name)}";
  containerIp = name: "${infra.wp-cluster.baseIP}.${toString (200 + instanceIndexOf name)}";
in {
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-*"];
    externalInterface = "enp3s0";
    enableIPv6 = false;
  };
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
          encode zstd
          file_server {
            hide .git .mirror .attic README.md README.de.md
          }
        '';
      }
    )
    // lib.genAttrs (map (name: "${name}.${infra.wp-cluster.baseDomain}") infra.wp-cluster.wpInstances)
    (
      domain: let
        name = lib.head (lib.strings.splitString "." domain);
      in {
        listenAddresses = [infra.wp-cluster.ip];
        # 'import intra' = caddy config is defined upstream role server already, assume its ok!
        extraConfig = ''
          import intra
          reverse_proxy ${containerIp name}:80
          request_body {
              max_size 128mb
          }
        '';
      }
    );
  systemd = {
    network.networks."${infra.namespace.user}".addresses = [
      {Address = "${infra.wp-cluster.ip}/32";}
    ];
    tmpfiles.rules =
      map (
        name: "d /var/lib/caddy/${name}.${infra.wp-cluster.valDomain} 0755 caddy caddy -"
      )
      infra.wp-cluster.wpInstances;
  };
  containers = lib.genAttrs infra.wp-cluster.wpInstances (
    name: let
      stateDir = "/var/www/${name}";
    in {
      additionalCapabilities = ["CAP_NET_ADMIN"];
      autoStart = true;
      privateNetwork = true;
      hostAddress = hostIp name;
      localAddress = containerIp name;
      config = {pkgs, ...}: let
        # nixpkgs' wordpress package strips every default theme and plugin
        # from wp-content in its installPhase, so a fresh install cannot pick
        # a theme and dies with: The theme directory "twentytwentyfive" does
        # not exist. Rebuild the installPhase without that removal so the
        # default themes (twentytwentyfive, twentytwentyfour,
        # twentytwentythree) and default plugins (akismet, hello) ship with
        # the core files.
        wpCore = pkgs.wordpress.overrideAttrs (_: {
          installPhase = ''
            runHook preInstall
            mkdir -p $out/share/wordpress
            cp -r . $out/share/wordpress
            rm $out/share/wordpress/wp-includes/certificates/ca-bundle.crt
            ln -s ${pkgs.cacert}/etc/ssl/certs/ca-no-trust-rules-bundle.crt $out/share/wordpress/wp-includes/certificates/ca-bundle.crt
            runHook postInstall
          '';
        });
      in {
        system.stateVersion = "26.11";
        systemd.tmpfiles.rules = ["d ${stateDir} 0750 ${name} nginx - -"];
        users.users.${name} = {
          isSystemUser = true;
          group = "nginx";
        };
        networking = {
          firewall.allowedTCPPorts = [80];
          useHostResolvConf = lib.mkForce false;
        };
        environment.systemPackages = [pkgs.wp-cli];
        services = {
          resolved = {
            enable = true;
            settings.Resolve.DNS = [
              "10.20.0.3"
              "10.20.0.2"
            ];
          };
          # The mariadb user <name>@localhost created below authenticates via
          # unix_socket (no password), so the php workers MUST run as the
          # same unix account as the mysql user.
          phpfpm.pools."${name}" = {
            user = name;
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
          nginx = {
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
              root = stateDir;
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
                    fastcgi_param HTTPS on;
                    fastcgi_intercept_errors on;
                    fastcgi_pass unix:/run/phpfpm/phpfpm.sock;
                    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                    fastcgi_read_timeout 300;
                }
              '';
            };
          };
          mysql = {
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
        };
        # Idempotent first-boot installer: copies the WordPress core from the
        # nix store into the stateful docroot and generates wp-config.php.
        # wp-cli runs as ${name} so unix_socket auth reaches mariadb as
        # ${name}@localhost; DB_HOST=localhost uses /run/mysqld/mysqld.sock.
        systemd.services."wp-init-${name}" = {
          description = "WordPress ${name}: install core files and wp-config.php";
          wantedBy = ["multi-user.target"];
          before = ["phpfpm-${name}.service"];
          after = ["mysql.service"];
          serviceConfig = {
            Type = "oneshot";
            User = name;
            Group = "nginx";
            Environment = ["HOME=/tmp"];
          };
          script = ''
            set -eu
            shopt -s nullglob
            wp() { ${pkgs.wp-cli}/bin/wp --path="${stateDir}" --skip-plugins --skip-themes "$@"; }
            if [ ! -e ${stateDir}/wp-includes/version.php ]; then
              echo "wp-init-${name}: installing WordPress core files into ${stateDir}"
              cp -r --no-preserve=mode ${wpCore}/share/wordpress/. ${stateDir}/
            fi
            # The docroot is stateful: instances deployed before the default
            # themes fix lack wp-content/themes and wp-content/plugins. Copy
            # each default theme/plugin that is still missing without ever
            # overwriting anything already on disk.
            mkdir -p ${stateDir}/wp-content/themes ${stateDir}/wp-content/plugins
            for src in ${wpCore}/share/wordpress/wp-content/themes/* ${wpCore}/share/wordpress/wp-content/plugins/*; do
              kind=$(basename "$(dirname "$src")")
              slug=$(basename "$src")
              if [ ! -e "${stateDir}/wp-content/''${kind}/''${slug}" ]; then
                echo "wp-init-${name}: adding default ''${kind}/''${slug}"
                cp -r --no-preserve=mode "$src" "${stateDir}/wp-content/''${kind}/''${slug}"
              fi
            done
            # WordPress must be able to create/serve uploads as ${name}.
            if [ ! -d ${stateDir}/wp-content/uploads ]; then
              mkdir -p ${stateDir}/wp-content/uploads
            fi
            if [ ! -e ${stateDir}/wp-config.php ]; then
              echo "wp-init-${name}: creating wp-config.php"
              wp config create \
                --dbname=${name} --dbuser=${name} --dbpass= --dbhost=localhost \
                --skip-check \
                --extra-php <<'PHP'
            define( 'DISALLOW_FILE_EDIT', true );
            PHP
            fi
            if wp core is-installed; then
              for opt in home siteurl; do
                cur=$(wp option get "$opt")
                case "$cur" in
                  http://*)
                    wp option update "$opt" "https://''${cur#http://}"
                    ;;
                esac
              done
            fi
          '';
        };
      };
    }
  );
}
