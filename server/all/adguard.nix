# adguard dns filter
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
  networking = {
    extraHosts = "${infra.adguard.ip} ${infra.adguard.hostname} ${infra.adguard.fqdn}";
    firewall = {
      allowedTCPPorts = [infra.port.dns];
      allowedUDPPorts = [infra.port.dns];
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [adguardian];
    variables = {
      ADGUARD_IP = infra.localhost.ip;
      ADGUARD_PORT = "${toString infra.adguard.localbind.port.http}";
      ADGUARD_PROTOCOL = "http";
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    adguardhome = {
      enable = true;
      mutableSettings = false;
      host = infra.localhost.ip;
      port = infra.adguard.localbind.port.http;
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
          bind_hosts = [infra.adguard.ip]; # bind only to outside interface
          bind_port = infra.port.dns;
          upstream_mode = "parallel";
          upstream_dns = infra.adguard.upstream_dns;
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
        user_rules = infra.adguard.user_rules;
        filters =
          map (url: {
            enabled = true;
            url = url;
          })
          infra.adguard.filter_lists;
      };
    };
    caddy.virtualHosts."${infra.adguard.fqdn}" = {
      listenAddresses = [infra.adguard.ip];
      extraConfig = ''import adminproxy ${toString infra.adguard.localbind.port.http}'';
    };
  };
}
