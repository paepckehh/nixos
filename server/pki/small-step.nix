{
  pkgs,
  config,
  ...
}: let
  infra = {
    lan = {
      domain = "lan";
      network = "192.168.80.0/24";
      namespace = "10-${infra.lan.domain}";
      services = {
        pki = {
          ip = "192.168.80.204";
          hostname = "pki";
          ports.tcp = 443;
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
    extraHosts = "${infra.lan.services.pki.ip} ${infra.lan.services.pki.hostname} ${infra.lan.services.pki.hostname}.${infra.lan.domain}";
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
      CA_FINGERPRINT = "b1671ec40f0ec0eb1db5720179f23890e6408bb1f6b5029fe2062eea3641ebff";
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
      step-acme = {
        initialHashedPassword = "$y$j9T$SSQCI4meuJbX7vzu5H.dR.$VUUZgJ4mVuYpTu3EwsiIRXAibv2ily5gQJNAHgZ9SG7"; # start
        description = "step ca acme provision account";
        uid = 32101;
        group = "step-acme";
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
      step-acme = {
        gid = 32101;
        members = ["step-acme"];
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
        # settings below are generated via cmd, any parameter change needs a re-regnerate and import here
        # step ca init --name="HomeLab" --dns="pki,pki.lan,192.168.80.204" --address="192.168.80.204:443" --provisioner="me@paepcke.de" --deployment-type standalone --remote-management
        commonName = "HomeLab";
        crt = "/var/lib/step-ca/certs/intermediate_ca.crt";
        backdate = "1m0s";
        dnsNames = ["${infra.lan.services.pki.hostname}.${infra.lan.domain}" "${infra.lan.services.pki.hostname}" "${infra.lan.services.pki.ip}"];
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
          enableAdmin = true;
          provisioners = [
            {
              name = "me@paepcke.de";
              type = "JWK";
              key = {
                use = "sig";
                kty = "EC";
                kid = "qItXvQihvW5IfTYCCDZLom2RetSAi7Vnvry40kHBWew";
                crv = "P-256";
                alg = "ES256";
                x = "dbvNKr4d4TQ8h4ANwEQLJF7XG9R24rBWYmGUMe-g-c4";
                y = "qdvoGNkiSd22uBf2KDWy60VS85XjTDNeJCO1pcpYwmI";
              };
              encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjYwMDAwMCwicDJzIjoiTFdsQV9DR2lyZFlsczJuaFJCNDRxQSJ9.WaeLOtH9uuCRdgKDdBNZbOwB0pq0qXfDVW2mYOngvy5VFqT81hqU_w.lJNmnCx7XoHGKCNO.nJTWkGWvGMxtqHx_MWfO0Ta6_ZUAExb4vT6790-qBagBSn2WeNB2gXthXfUJ7Rpur0La3r-v7_NIKQuPN6bGfjIQUhnHX7XkEZcWRFg2dcizWr0MDBmwDH33l7ZoIY2Vjf9k5S5hUW3ZmOz9uzU5YGNqvxhWPV42y_hdQnRczmkCD_EwUtysuERMYGagosXuLOfZ6Dfr20kje_277fpUjFe6EYrCQrc4QonZKVKxzmrNJBxt7pEAUGEN5e8nxqNknV8FE3CGjcEmKlhqukphmT9PPuPhl2FtNwL63QNibDs6jm6ktpdl7YNs3ek3LwMoTElq_ERr3WyGN38h9AE.sNGfQBQ4hf3oNfpp0j0BNA";
            }
            {
              name = "acme";
              type = "ACME";
              claims = {
                allowRenewalAfterExpiry = false;
                disableSmallstepExtensions = false;
                enableSSHCA = true;
                disableRenewal = false;
                options = {
                  x509 = {};
                  ssh = {};
                };
              };
            }
          ];
        };
      };
    };
  };
}
