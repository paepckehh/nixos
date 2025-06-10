{config, ...}: {
  ##################
  #-=# SECURITY #=-#
  ##################
  security = {
    pki = {
      certificates = [
        ''
          pki.lan 2025-06-08
          =========
          -----BEGIN CERTIFICATE-----
          MIIBjDCCATGgAwIBAgIQNj7mKyVrh4rLuGw5lLN0+jAKBggqhkjOPQQDAjAkMQww
          CgYDVQQKEwNwa2kxFDASBgNVBAMTC3BraSBSb290IENBMB4XDTI1MDYwODA5NDcw
          MFoXDTM1MDYwNjA5NDcwMFowJDEMMAoGA1UEChMDcGtpMRQwEgYDVQQDEwtwa2kg
          Um9vdCBDQTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABD92N08xb93+ZrDmNeOd
          2I+liCIyZ+nkKSwEPFRsekePbNdMdkhMvSTA5OCFrcS7fd4j8XvoD9zTQ2yU6bux
          AemjRTBDMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEBMB0GA1Ud
          DgQWBBQy9W7Gjy4/8gIYC5Eo/kstbeyYpDAKBggqhkjOPQQDAgNJADBGAiEAmlIW
          ICKWaXYlNaedHf5pxD7c8nApPHVZdyzrSHOU0oACIQDQ5AHlIa0je8XE1eUmo2ST
          pJoQJ7cIFTey4XKTT0+IBA==
          -----END CERTIFICATE-----
        ''
      ];
    };
  };
}
