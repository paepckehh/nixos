{
  pkgs,
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
          defaultTLSCertDuration = "1440h0m0s";
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.namespace}.addresses = [{Address = "${infra.lan.services.pki.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.pki.ip} ${infra.lan.services.pki.hostname} ${infra.lan.services.pki.hostname}.${infra.lan.services.pki.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.pki.ports.tcp];
  };

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

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      step = {
        initialHashedPassword = null; # no interactive logon
        description = "step ca acme pki service account";
        uid = 32100;
        group = "step";
        createHome = false;
        isNormalUser = false;
        isSystemUser = true;
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
      };
    };
    groups = {
      step = {
        gid = 32100;
        members = ["step"];
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    step-ca = {
      enable = true;
      address = "${infra.lan.services.pki.ip}";
      port = infra.lan.services.pki.ports.tcp;
      intermediatePasswordFile = config.age.secrets.pki-pwd.path;
      settings = {
        # regenerateCA:
        # sudo rm -rf /var/lib/private/step-ca/*
        # step ca init
        # --name="corpCA" --dns="pki,pki.corp,pki.adm.corp,10.20.0.20" --address="10.20.0.20:443" --provisioner="pki@adm.corp" --deployment-type standalone --remote-management
        # sudo mv /root/.step-ca/* /var/lib/private/step-ca/
        # sudo sh sync.sh
        # renew rootCA anchor trust everywhere (see above, clientAddRoot, ...)
        commonName = "corpCA";
        crt = "/var/lib/step-ca/certs/intermediate_ca.crt";
        backdate = "1m0s";
        dnsNames = ["${infra.lan.services.pki.hostname}.${infra.lan.services.pki.domain}" "${infra.lan.services.pki.hostname}" "${infra.lan.services.pki.ip}"];
        federatedRoots = null;
        key = "/var/lib/step-ca/secrets/intermediate_ca_key";
        root = "/var/lib//step-ca/certs/root_ca.crt";
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
                defaultTLSCertDuration = "${infra.lan.services.pki.defaultTLSCertDuration}";
                disableSmallstepExtensions = true;
                disableRenewal = false;
                enableSSHCA = false;
                minTLSCertDuration = "720h0m0s";
                maxTLSCertDuration = "3072h0m0s";
              };
            }
          ];
        };
      };
    };
  };
}
