{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      settings = {
        redis = {
          username = "redis-blocky"; # config.services.redis.servers.blocky.user;
          password = "redis-blocky"; # config.services.redis.servers.blocky.masterAuth;
          # sentinelUsername = null; # config.services.redis.server.blocky.user;
          # sentinelPassword = null; # config.services.redis.server.blocky.masterAuth;
          # sentinelAddresses = []; # ["blocky-sentinel1:26379" "blocky-sentinel2:26379" "blocky-sentinel3:26379"];
          # address = config.services.redis.servers.blocky.unixSocket;
          address = "127.0.0.1:6379";
          database = 2;
          required = false;
          connectionAttempts = 5;
          connectionCooldown = "5s";
        };
      };
    };
    redis = {
      servers = {
        blocky = {
          # extraParams = ["--sentinel"];
          # logfile = "/var/lib/redis-blocky/redis.log";
          # requirePassFile = null; # /run/keys/redis-password
          # unixSocket = "/run/redis-blocky/redis.sock";
          # unixSocketPerm = 660;
          user = "redis-blocky";
          group = "redis-blocky";
          masterAuth = "redis-blocky";
          requirePass = "redis-blocky";
          enable = true;
          appendFsync = "no"; # no, always, everysec
          appendOnly = true;
          bind = "127.0.0.1";
          databases = 16;
          logLevel = "notice"; # notice, debug
          maxclients = 10000;
          openFirewall = false;
          port = 6379;
          save = [[900 1] [360 1000] [120 100000]]; # [];
          slowLogLogSlowerThan = 1000;
          slowLogMaxLen = 1000;
          syslog = true;
        };
      };
    };
  };
}
