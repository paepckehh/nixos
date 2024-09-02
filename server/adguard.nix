{
  config,
  lib,
  pkgs,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    resolvconf = {
      enable = true;
      useLocalResolver = true;
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [adguardian];
    variables = {
      ADGUARD_IP = "127.0.0.1";
      ADGUARD_PORT = "3232";
      ADGUARD_PROTOCOL = "http";
      ADGUARD_USERNAME = "";
      ADGUARD_PASSWORD = "";
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    adguardhome = {
      enable = true;
      mutableSettings = false;
      host = "127.0.0.1";
      port = 3232;
      openFirewall = false;
      settings = {
        dhcp.enabled = false;
        tls.enabled = false;
        dns = {
          anonymize_client_ip = false;
          aaaa_disabled = true;
          enable_dnssec = true;
          bind_hosts = ["127.0.0.1"];
          bind_port = 53;
          upstream_mode = "parallel";
          upstream_dns = [
            "sdns://AQYAAAAAAAAADzEyOC4xMjcuMTA0LjEwOCAxM3KtWVYywkFrhy8Jj4Ub3bllKExsvppPGQlkMNupWh4yLmRuc2NyeXB0LWNlcnQuY3J5cHRvc3Rvcm0uaXM"
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
          private_networks = ["192.168.0.0/8" "127.0.0.0/16"];
          use_private_ptr_resolvers = false;
          serve_http3 = false;
          use_http3_upstreams = true;
          serve_plain_dns = true;
          hostsfile_enabled = true;
        };
        querylog = {
          enabled = true;
          interval = "2160h";
        };
        statistics = {
          enabled = true;
          interval = "2160h";
        };
        filtering = {
          safe_search.enabled = true;
          filtering_enabled = true;
          protection_enabled = true;
          parental_enabled = false;
        };
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
  };
}
