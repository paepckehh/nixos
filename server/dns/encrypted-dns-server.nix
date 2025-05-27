{
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    encrypted-dns-server = {
      enable = true;
      settings = {
        state_file = "/var/lib/encrypted-dns-server/encrypted-dns.state";
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
