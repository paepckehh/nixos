# pki web-pki step-ca
# regenerateCA:
# sudo rm -rf /var/lib/private/step-ca/*
# step ca init
# --name="corpCA" --dns="pki,pki.corp,pki.adm.corp,10.20.0.20" --address="10.20.0.20:443" --provisioner="pki@adm.corp" --deployment-type standalone --remote-management
# manual cat /root/.step/certs/* >> /etc/nixos/client/addrootCA-small-step.nix
# manual as root: mv /root/.step/* /var/lib/private/step-ca/
# sudo sh sync.sh
# renew rootCA anchor trust everywhere (see above, clientAddRoot, ...)
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
  networking.extraHosts = "${infra.pki.ip} ${infra.pki.hostname} ${infra.pki.fqdn}";

  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../../client/addrootCA-small-step.nix
  ];

  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    pki-pwd = {
      file = ../../modules/resources/pki-pwd.age;
      owner = "step";
      group = "step";
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.step = {};
    users = {
      step = {
        group = "step";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [step-kms-plugin step-cli];
    shellAliases = {};
    variables = {
      STEPPATH = "/var/lib/step-ca";
      CA_FINGERPRINT = "4491d25c90d38427597b154164de4952a9fa248143684f8b559448f9efd61e13";
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.step-ca = {
    after = ["socket.target"];
    wants = ["socket.target"];
    wantedBy = ["multi-user.target"];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    step-ca = {
      enable = true;
      address = infra.pki.ip;
      port = infra.port.https;
      intermediatePasswordFile = config.age.secrets.pki-pwd.path;
      settings = {
        commonName = "${infra.site.displayName}-CA";
        crt = "/var/lib/step-ca/certs/intermediate_ca.crt";
        backdate = "10m0s";
        dnsNames = ["${infra.pki.fqdn}" "${infra.pki.hostname}"];
        federatedRoots = null;
        key = "/var/lib/step-ca/secrets/intermediate_ca_key";
        root = "/var/lib/step-ca/certs/root_ca.crt";
        template = {};
        logger.format = "text";
        db = {
          type = "badgerv2";
          dataSource = "/var/lib/step-ca/db";
          badgerFileLoadingMode = "";
        };
        tls = {
          cipherSuites = ["TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256" "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"];
          minVersion = 1.3;
          maxVersion = 1.3;
          renegotiation = false;
        };
        authority = {
          provisioners = [
            {
              name = "acme";
              type = "ACME";
              claims = {
                allowRenewalAfterExpiry = true;
                defaultTLSCertDuration = infra.pki.certs.defaultTLSCertDuration;
                disableSmallstepExtensions = true;
                disableRenewal = false;
                enableSSHCA = false;
                minTLSCertDuration = "1h0m0s";
                maxTLSCertDuration = "306600h0m0s"; # 35 years
              };
            }
          ];
        };
      };
    };
  };
}
