# vaultwarden bitwarden password safe
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
  networking.extraHosts = "${infra.vault.ip} ${infra.vault.hostname} ${infra.vault.fqdn}";

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [libargon2 openssl];

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.vaultwarden = {
    after = ["socket.target"];
    wants = ["socket.target"];
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
      environmentFile = config.age.secrets.vault.path;
      config = {
        ROCKET_ADDRESS = infra.localhost.ip;
        ROCKET_PORT = infra.vault.localbind.port.http;
        ROCKET_LOG = "info";
        SMTP_HOST = infra.smtp.fqdn;
        SMTP_PORT = infra.port.smtp;
        SMTP_SSL = false;
        SMTP_FROM = infra.admin.email;
        SMTP_FROM_NAME = infra.admin.email;
        # SIGNUPS_DOMAINS_WHITELIST = infra.smtp.domain;
        # HIBP_API_KEY = infra.vault.api_hibp;
      };
    };
    caddy.virtualHosts."${infra.vault.fqdn}" = {
      listenAddresses = [infra.vault.ip];
      extraConfig = ''import intraproxy ${toString infra.vault.localbind.port.http}'';
    };
  };
}
