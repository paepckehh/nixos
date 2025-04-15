{
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3030;
          domain = "grafana.lan";
          root_url = "https://grafana.lan:3030/";
          serve_from_sub_path = true;
        };
      };
    };
  };
}
