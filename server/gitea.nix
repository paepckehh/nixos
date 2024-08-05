{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    gitea = {
      enable = true;
      appName = "internal git service";
      server = {
        protocol = "http";
        http_port = "3000";
        http_addr = "127.0.0.1";
        domain = "git.lan";
        disable_ssh = false;
        ssh_port = "22";
      };
    };
  };
}
