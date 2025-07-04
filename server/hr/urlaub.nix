{lib, ...}: {
  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers = {
        urlaub = {
          image = "urlaubsverwaltung/urlaubsverwaltung:latest";
          ports = ["127.0.0.1:9901:8080"];
          environment = {};
        };
      };
    };
  };
}
