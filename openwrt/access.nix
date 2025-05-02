{
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      "axt" = "ssh -p 6623 root@192.168.8.1   service uhttpd start && ssh -p 6623 -L127.0.0.1:8080:127.0.0.1:8080 root@192.168.8.1";
      "axt.backup" = "ssh -p 6623 root@192.168.8.1 uci show | sed '/.key=/d'";
      "rpi2" = "ssh -p 6623 root@192.168.8.251 service uhttpd start && ssh -p 6623 -L127.0.0.1:8081:127.0.0.1:8080 root@192.168.8.251";
      "rpi2.backup" = "ssh -p 6623 root@192.168.8.251 uci show | sed '/.key=/d'";
      "b3000" = "ssh -p 6623 root@192.168.8.250 service uhttpd start && ssh -p 6623 -L127.0.0.1:8082:127.0.0.1:8080 root@192.168.8.250";
      "b3000.backup" = "ssh -p 6623 root@192.168.8.250 uci show | sed '/.key=/d'";
    };
  };
}
