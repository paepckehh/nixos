{
  config,
  pkgs,
  ...
}: {
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers = {
        onlyoffice = {
          image = "onlyoffice/documentserver";
          ports = ["127.0.0.1:80:80"];
          environment = {
            JWT_SECRET = "gjreopogh3QvVitrbgi3ongjniwveVE";
          };
          volumes = [
            # sudo mkdir -p /var/log/onlyoffice /var/lib/onlyoffice /var/lib/onlyoffice-db /var/lib/onlyoffice-www/onlyoffice/Data
            "/var/log/onlyoffice:/var/log/onlyoffice"
            "/var/lib/onlyoffice:/var/lib/onlyoffice"
            "/var/lib/onlyoffice-db:/var/lib/postgresql"
            "/var/lib/onlyoffice-www/onlyoffice/Data:/var/www/onlyoffice/Data"
          ];
        };
      };
    };
  };
}
