{config, ...}: {
  ##################
  #-=# SECURITY #=-#
  ##################
  security = {
    pki = {
      certificates = [
        ''
          pvz.lan
          =========
          -----BEGIN CERTIFICATE-----
          MIIGUDCCBTigAwIBAgIDD8KWMA0GCSqGSIb3DQEBBQUAMIGMMQswCQYDVQQGEwJJ
          TDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0
          ...
          -----END CERTIFICATE-----
        ''
      ];
    };
  };
}
