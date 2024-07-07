{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    journald.upload = {
      enable = false;
      settings = {
        Upload.URL = "https://192.168.0.250:19532";
        ServerKeyFile = "/etc/ca/client.key";
        ServerCertificateFile = "/etc/ca/client.pem";
        TrustedCertificateFile = "/etc/ca/journal-server.pem";
      };
    };
  };
}
