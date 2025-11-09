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
    localhostPortOffset = 7000;
    id = {
      admin = 0;
      user = 6;
    };
    port = {
      smtp = 25;
      http = 80;
      https = 443;
      webapp = [infra.port.http infra.port.https];
    };
    domain = {
      tld = "corp";
      admin = "adm.${infra.domain.tld}";
      user = "dbt.${infra.domain.tld}";
    };
    cidr = {
      admin = "${infra.net.user}.${toString infra.id.admin}.0/24";
      user = "${infra.net.user}.${toString infra.id.user}.0/23";
    };
    net = {
      prefix = "10.20";
      admin = "${infra.net.prefix}.${toString infra.id.admin}";
      user = "${infra.net.prefix}.${toString infra.id.user}";
    };
    namespace = {
      admin = "${toString infra.id.admin}";
      user = "${toString infra.id.user}";
    };
    pki = {
      acmeContact = "acme@${infra.pki.fqdn}";
      caFile = "/etc/ca.crt";
      hostname = "pki";
      domain = infra.domain.admin;
      maildomain = "debitor.de";
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      url = "https://${infra.pki.fqdn}/acme/acme/directory";
    };
    smtp = {
      hostname = "smtp";
      domain = infra.domain.admin;
      fqdn = "${infra.smtp.hostname}.${infra.smtp.domain}";
      maildomain = "debitor.de";
    };
    vault = {
      net = 6;
      id = 129;
      name = "vault";
      api_hibp = "";
      hostname = infra.vault.name;
      domain = infra.domain.user;
      fqdn = "${infra.vault.hostname}.${infra.vault.domain}";
      ip = "${infra.net.user}.${toString infra.vault.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost;
        ports.http = 7000 + infra.vault.id;
      };
    };
  };
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.vault.ip} ${infra.vault.hostname} ${infra.vault.fqdn}";

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [argon2 openssl];

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.vaultwarden = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
  };

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
        SMTP_FROM_NAME = "${infra.vault.name}@${infra.smtp.maildomain}";
        SIGNUPS_DOMAINS_WHITELIST = infra.smtp.maildomain;
        HIBP_API_KEY = infra.vault.api_hibp;
      };
    };
    caddy.virtualHosts."${infra.vault.fqdn}" = {
      listenAddresses = [infra.vault.ip];
      extraConfig = ''
        reverse_proxy ${infra.vault.localbind.ip}:${toString infra.vault.localbind.ports.http}
        @not_intranet { not remot_ip ${infra.vault.network} }
        respond @not_intranet 403
        respond /admin* "The admin panel is disabled, please configure the 'ADMIN_TOKEN' variable to enable it"'';
    };
  };
}
