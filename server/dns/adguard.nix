{
  pkgs,
  lib,
  config,
  ...
}: let
  infra = {
    lan = {
      domain = "corp";
      namespace = "00-${infra.lan.domain}";
      services = {
        pki = {
          ip = "10.20.0.20";
          hostname = "pki";
          ports.tcp = 443;
          domain = "adm.${infra.lan.domain}";
          network = "10.20.0.0/24";
        };
        adguard = {
          ip = "10.20.0.53";
          hostname = "adguard";
          domain = "adm.${infra.lan.domain}";
          network = "10.20.0.0/24";
          ports = {
            dns = 53;
            tcp = 443;
          };
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7053;
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
    {Address = "${infra.lan.services.adguard.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.adguard.ip} ${infra.lan.services.adguard.hostname} ${infra.lan.services.adguard.hostname}.${infra.lan.services.adguard.domain}";
    firewall = {
      allowedTCPPorts = [infra.lan.services.adguard.ports.dns infra.lan.services.adguard.ports.tcp];
      allowedUDPPorts = [infra.lan.services.adguard.ports.dns];
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [adguardian];
    variables = {
      ADGUARD_IP = "${infra.lan.services.adguard.localbind.ip}";
      ADGUARD_PORT = "${toString infra.lan.services.adguard.localbind.ports.tcp}";
      ADGUARD_PROTOCOL = "http";
      ADGUARD_USERNAME = "admin";
      ADGUARD_PASSWORD = "admin";
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    adguardhome = {
      enable = true;
      mutableSettings = false;
      host = "${infra.lan.services.adguard.localbind.ip}";
      port = infra.lan.services.adguard.localbind.ports.tcp;
      openFirewall = false;
      settings = {
        dhcp.enabled = false;
        tls.enabled = false;
        language = "en";
        dns = {
          anonymize_client_ip = false;
          ratelimit = 1024;
          ratelimit_whitelist = ["127.0.0.1" "10.20.0.0"]; # they are all /24 networks
          refuse_any = true;
          aaaa_disabled = true;
          enable_dnssec = true;
          bind_hosts = ["${infra.lan.services.adguard.ip}"]; # bind only to outside interface
          bind_port = infra.lan.services.adguard.ports.dns;
          upstream_mode = "parallel";
          upstream_dns = [
            "sdns://AQcAAAAAAAAADjIzLjE0MC4yNDguMTAwIFa3zBQNs5jjEISHskpY7WSNK4sLj_qrbFiLk5tSBN1uGTIuZG5zY3J5cHQtY2VydC5kbnNjcnkucHQ"
            "sdns://AQcAAAAAAAAADzE0Ny4xODkuMTQwLjEzNiCL7wgLXnE-35sDhXk5N1RNpUfWmM2aUBcMFlst7FPdnRkyLmRuc2NyeXB0LWNlcnQuZG5zY3J5LnB0"
            "sdns://AQcAAAAAAAAADDIzLjE4NC40OC4xOSCwg3q2XK6z70eHJhi0H7whWQ_ZWQylhMItvqKpd9GtzRkyLmRuc2NyeXB0LWNlcnQuZG5zY3J5LnB0"
            "sdns://AQcAAAAAAAAADzE3Ni4xMTEuMjE5LjEyNiDzuja5nmAyDvA5jakqkuLQEtb245xsAhNwJYDLkKraKhkyLmRuc2NyeXB0LWNlcnQuZG5zY3J5LnB0"
          ];
          bootstrap_dns = [
            "9.9.9.9"
            "9.9.9.10"
            "1.1.1.1"
            "8.8.8.8"
          ];
          private_networks = ["127.0.0.0/8" "10.0.0.0/8" "192.168.0.0/16"]; #
          use_private_ptr_resolvers = false;
          serve_http3 = false;
          use_http3_upstreams = true;
          serve_plain_dns = true;
          hostsfile_enabled = false;
          cache_size = 33554432;
          cache_ttl_min = 3600;
          cache_optimistic = true;
        };
        querylog = {
          enabled = true;
          interval = "360h";
        };
        statistics = {
          enabled = true;
          interval = "360h";
        };
        filtering = {
          safesearch_enabled = true;
          blocking_mode = "nxdomain";
          parental_block_host = "family-block.dns.adguard.com"; # redirect to corp internal websites instead!
          safebrowsing_block_host = "standard-block.dns.adguard.com"; #
          safebrowsing_cache_size = 33554432;
          safesearch_cache_size = 33554432;
          parental_cache_size = 33554432;
          cache_time = 86400;
          filters_update_interval = 12;
          blocked_response_ttl = 3600;
          filtering_enabled = true;
          parental_enabled = true;
          safebrowsing_enabled = true;
          protection_enabled = true;
        };
        clients = {
          runtime_sources = {
            whois = false;
            arp = false;
            rdns = false;
            dhcp = false;
            hosts = false;
          };
        };
        user_rules = [
          "@@||bahn.de^$important"
        ];
        filters =
          map (url: {
            enabled = true;
            url = url;
          }) [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://easylist.to/easylist/easylist.txt"
            "https://easylist.to/easylistgermany/easylistgermany.txt"
            "https://easylist-downloads.adblockplus.org/antiadblockfilters.txt"
            "https://secure.fanboy.co.nz/fanboy-annoyance.txt"
          ];
      };
    };
    caddy = {
      enable = true;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      virtualHosts."${infra.lan.services.adguard.hostname}.${infra.lan.services.adguard.domain}".extraConfig = ''
        bind ${infra.lan.services.adguard.ip}
        reverse_proxy ${infra.lan.services.adguard.localbind.ip}:${toString infra.lan.services.adguard.localbind.ports.tcp}
        tls acme@${infra.lan.services.pki.hostname}.${infra.lan.services.pki.domain} {
              ca_root /etc/ca.crt
              ca https://${infra.lan.services.pki.hostname}.${infra.lan.services.pki.domain}/acme/acme/directory
        }
        @not_intranet {
          not remote_ip ${infra.lan.services.adguard.network}
        }
        basic_auth {
          admin $2a$14$GrYizTUqc495HtJI3I2/FuIQv22w1FArhkzGBsmqTIRJlTMdQjAEC
        }
        respond @not_intranet 403
      '';
    };
  };
}
