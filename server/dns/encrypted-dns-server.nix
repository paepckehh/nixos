{
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    encrypted-dns-server = {
      enable = true;
      settings = {
        listen_addrs = [
          {
            local = "127.0.0.1:5443";
            external = "127.0.0.1:5443";
          }
        ];
      };
    };
  };
}
