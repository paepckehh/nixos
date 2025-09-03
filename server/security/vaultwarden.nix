{
  lib,
  config,
  pkgs,
  ...
}: let
  infra = {
    admin = "admin";
    contact = "it@${infra.smtp.maildomain}";
    localhost = "127.0.0.1";
    ports = {
      smtp = 25;
      http = 80;
      https = 443;
    };
    pki = {
      acmeContact = "acme@${infra.pki.fqdn}";
      caFile = "/etc/ca.crt";
      hostname = "pki";
      domain = "adm.corp";
      maildomain = "debitor.de";
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      url = "https://${infra.pki.fqdn}/acme/acme/directory";
    };
    smtp = {
      hostname = "smtp";
      domain = "adm.corp";
      fqdn = "${infra.smtp.hostname}.${infra.smtp.domain}";
    };
    vault = {
      net = 6;
      id = 129;
      hostname = "vault";
      domain = "dbt.corp";
      fqdn = "${infra.vault.hostname}.${infra.vault.domain}";
      ip = "10.20.${toString infra.vault.net}.${toString infra.vault.id}";
      network = "10.20.${toString infra.vault.net}.0/23";
      namespace = "${toString infra.vault.net}";
      localbind = {
        ip = infra.localhost;
        ports.http = 7000 + infra.vault.id;
      };
    };
  };
in {
  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets.vault = {
        file = ../../modules/resources/vault.age;
        owner = "vaultwarden";
        group = "vaultwarden";
      };
  };
  
  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.vaultwarden = {};
    users = {
      vaultwarden = {
        group = "vaultwarden";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };
  
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [argon2 openssl];

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.vault.namespace}.addresses = [
    {Address = "${infra.vault.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.vault.ip} ${infra.vault.hostname} ${infra.vault.fqdn}";
    firewall.allowedTCPPorts = [infra.ports.http infra.ports.https];
  };:wq

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    vaultwarden = {
      enable = true;
      # ENV ADMIN_TOKEN, see https://github.com/dani-garcia/vaultwarden/wiki/Enabling-admin-page
      # echo -n "secret-pass..." | argon2 "$(openssl rand -base64 32)" -e -id -k 65540 -t 3 -p 4
      environmentFile = config.age.secrets.path; 
      config = {
        ROCKET_ADDRESS = "${infra.vault.localbind.ip}";
        ROCKET_PORT = infra.vault.localbind.ports.http;
        ROCKET_LOG = "info";
        SMTP_HOST = "${infra.smtp.fqdn}";
        SMTP_PORT = infra.ports.smtp;
        SMTP_SSL = false;
        SMTP_FROM = "${infra.contact}";
        SMTP_FROM_NAME = "${infra.vault.hostname}";
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.vault.fqdn}".extraConfig = ''
        bind ${infra.vault.ip}
        reverse_proxy ${infra.vault.localbind.ip}:${toString infra.vault.localbind.ports.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.vault.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.vault.hostname}.log
        }'';
    };
  };
}
