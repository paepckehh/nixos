{
  config,
  lib,
  pkgs,
  ...
}: let
  infra = {
    lan = {
      domain = "corp";
      namespace = "00-${infra.lan.domain}";
      services = {
        pki = {
          ip = "10.20.0.20";
          network = "10.20.0.0/24";
          hostname = "pki";
          ports.tcp = 443;
          domain = "adm.${infra.lan.domain}";
        };
        roundcube = {
          ip = "10.20.0.22";
          network = "10.20.0.0/24";
          hostname = "mail";
          domain = "adm.${infra.lan.domain}";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7022;
          };
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.roundcube.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.roundcube.ip} ${infra.lan.services.roundcube.hostname} ${infra.lan.services.roundcube.hostname}.${infra.lan.services.roundcube.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.roundcube.ports.tcp];
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.acme = {
    acceptTerms = true;
    certs."${config.services.roundcube.hostName}" = {
      email = "acme@${infra.lan.services.pki.hostname}.${infra.lan.services.pki.domain}";
      server = "https://${infra.lan.services.pki.hostname}.${infra.lan.services.pki.domain}/acme/acme/directory";
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    roundcube = {
      enable = true;
      configureNginx = true;
      dicts = with pkgs.aspellDicts; [de en];
      maxAttachmentSize = 20; # MB
      package = pkgs.roundcube.withPlugins (plugins: [plugins.persistent_login plugins.contextmenu]);
      hostName = "${infra.lan.services.roundcube.hostname}.${infra.lan.services.roundcube.domain}";
    };
    nginx = {
      sslProtocols = "TLSv1.3";
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedZstdSettings = true;
      recommendedOptimisation = true;
      virtualHosts."${config.services.roundcube.hostName}" = {
        forceSSL = true;
        enableACME = true;
        listen = [{addr = "${infra.lan.services.roundcube.ip}";}];
      };
    };
  };
}
