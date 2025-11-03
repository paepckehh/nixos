{...}: let
  infra = {
    lan = {
      services = {
        caldav = {
          ip = "10.20.6.127";
          ports.tcp = 443;
          hostname = "caldav";
          domain = "dbt.corp";
          fqdn = "${infra.lan.services.caldav.hostname}.${infra.lan.services.caldav.domain}";
          url = "https://${infra.lan.services.caldav.fqdn}";
        };
        webcal = {
          ip = "10.20.6.128";
          ports.tcp = 443;
          hostname = "calendar";
          domain = "dbt.corp";
          namespace = "06-corp";
          fqdn = "${infra.lan.services.webcal.hostname}.${infra.lan.services.webcal.domain}";
          url = "https://${infra.lan.services.webcal.fqdn}";
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 8128;
          };
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.services.webcal.namespace}.addresses = [{Address = "${infra.lan.services.webcal.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.webcal.ip} ${infra.lan.services.webcal.hostname} ${infra.lan.services.webcal.fqdn}";
    firewall.allowedTCPPorts = [infra.lan.services.webcal.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    open-web-calendar = {
      enable = true;
      domain = "${infra.lan.services.webcal.fqdn}";
      settings = {
        title = "my corp calendar";
        language = "de";
      };
    };
    nginx = {
      virtualHosts."${infra.lan.services.webcal.fqdn}" = {
        forceSSL = false;
        enableACME = false;
      };
    };
  };
}
