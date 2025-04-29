{
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      axt = "ssh -p 6623 -L127.0.0.1:8080:127.0.0.1:8080 root@192.168.8.1 service uhttpd start";
      rpi2 = "ssh -p 6623 -L127.0.0.1:8081:127.0.0.1:8080 root@192.168.8.251 service uhttpd start";
      b3000 = "ssh -p 6623 -L127.0.0.1:8082:127.0.0.1:8080 root@192.168.8.250 service uhttpd start";
    };
  };
}
