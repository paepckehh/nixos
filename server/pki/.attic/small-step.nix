{
  pkgs,
  config,
  ...
}: let
  infra = {
    lan = {
      domain = "adm.corp";
      network = "10.20.0.0/24";
      namespace = "0-${infra.lan.domain}";
      services = {
        pki = {
          ip = "10.20.0.20";
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
      CA_FINGERPRINT = "4491d25c90d38427597b154164de4952a9fa248143684f8b559448f9efd61e13";
    };
    etc."ca.crt".text = ''
      -----BEGIN CERTIFICATE-----
      MIIBlDCCATqgAwIBAgIRAP/nRtFYTkwwhPMA68Kfx2gwCgYIKoZIzj0EAwIwKDEO
      MAwGA1UEChMFbGFuQ0ExFjAUBgNVBAMTDWxhbkNBIFJvb3QgQ0EwHhcNMjUwNjE1
      MDUxNTAwWhcNMzUwNjEzMDUxNTAwWjAoMQ4wDAYDVQQKEwVsYW5DQTEWMBQGA1UE
      AxMNbGFuQ0EgUm9vdCBDQTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABOE65Y9t
      m4J3qX3igSH67wehIUAxSCRkunooZ4xqkm49/rAzgNQFGxOnrMMxndeN1INaeY+7
      WsR0QNUekckc4jmjRTBDMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/
      AgEBMB0GA1UdDgQWBBTD95MPyexPUCxaG3De27ApOjuprjAKBggqhkjOPQQDAgNI
      ADBFAiA5QC8zU6/VU/axGbSbxe7TdTuI0LgX2gMpSkH7HVZLBgIhAOQw/BgrOOZS
      Wb1brPD68ypgeGU9NrA4SemVi+XsN+e5
      -----END CERTIFICATE-----
      -----BEGIN CERTIFICATE-----
      MIIBvTCCAWOgAwIBAgIRAJ47hVlrFzycM6gedFlQUbIwCgYIKoZIzj0EAwIwKDEO
      MAwGA1UEChMFbGFuQ0ExFjAUBgNVBAMTDWxhbkNBIFJvb3QgQ0EwHhcNMjUwNjE1
      MDUxNTAxWhcNMzUwNjEzMDUxNTAxWjAwMQ4wDAYDVQQKEwVsYW5DQTEeMBwGA1UE
      AxMVbGFuQ0EgSW50ZXJtZWRpYXRlIENBMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcD
      QgAEEnMyS1oivljTdBPxbjAVDlJD4fY0pEBACdBTiuY2/VUeHPEwSMT2sG+CO3RN
      9KOZ4ApH5l2T3/UHN8r5+ws+r6NmMGQwDgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB
      /wQIMAYBAf8CAQAwHQYDVR0OBBYEFDSMIKNjoZjMu5HxCayoS1ua8No+MB8GA1Ud
      IwQYMBaAFMP3kw/J7E9QLFobcN7bsCk6O6muMAoGCCqGSM49BAMCA0gAMEUCIQDO
      WH+hD0Nc1es6mHkCi+I0asel9MfbcPpjRa7et+wNdAIgX4c84BmqicG0W1R61oYh
      hYfBxMqBowvjt5rSB5yiJQ0=
      -----END CERTIFICATE-----
    '';
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
        # settings below are generated via cmd, any parameter change needs a re-regnerate and import here
        # step ca init --name="corp" --dns="pki,pki.corp,pki.adm.corp,10.20.0.20" --address="10.20.0.20:443" --provisioner="pki@pki.corp" --deployment-type standalone --remote-management
        commonName = "corp";
        crt = "/var/lib/step-ca/certs/intermediate_ca.crt";
        backdate = "1m0s";
        dnsNames = ["${infra.lan.services.pki.hostname}.${infra.lan.domain}" "${infra.lan.services.pki.hostname}" "${infra.lan.services.pki.ip}"];
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
              name = "pki@dbt.corp";
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
                allowRenewalAfterExpiry = true;
                defaultTLSCertDuration = "8766h0m0s";
                disableSmallstepExtensions = true;
                disableRenewal = false;
                enableSSHCA = false;
                minTLSCertDuration = "4834h0m0s";
                maxTLSCertDuration = "43830h0m0s";
              };
            }
          ];
        };
      };
    };
  };
}
