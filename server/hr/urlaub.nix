{lib,..}: {
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers = {
        whoogle = {
          image = "urlaubsverwaltung/urlaubsverwaltung:latest";
          ports = ["127.0.0.1:9901:8080"];
          environment = {};
        };
      };
    };
  };
}
