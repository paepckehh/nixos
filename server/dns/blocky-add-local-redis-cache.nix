{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      settings = {
        redis = {
          address = config.services.redis.servers.blocky.unixSocket; # services.redis.servers.blocky-cache.bind; master if sentinel is active
          username = null; # config.services.redis.servers.blocky.user;
          password = null; # config.services.redis.servers.blocky.masterAuth;
          database = 2;
          required = false;
          connectionAttempts = 128;
          connectionCooldown = "10s";
          sentinelUsername = null; # config.services.redis.server.blocky.user;
          sentinelPassword = null; # config.services.redis.server.blocky.masterAuth;
          sentinelAddresses = []; # ["blocky-sentinel1:26379" "blocky-sentinel2:26379" "blocky-sentinel3:26379"];
        };
      };
    };
    redis = {
      servers = {
        blocky = {
          enable = true;
          appendFsync = "no"; # no, always, everysec
          appendOnly = true;
          bind = "127.0.0.1";
          databases = 16;
          # extraParams = ["--sentinel"];
          group = "redis-blocky";
          logLevel = "notice";
          logfile = "/dev/null"; # /var/log/redis.log (see syslog)
          masterAuth = "redis-blocky";
          maxclients = 10000;
          openFirewall = false;
          port = 6379;
          requirePass = null;
          requirePassFile = null; # /run/keys/redis-password
          save = [[900 1] [360 1000] [120 100000]]; # [];
          slowLogLogSlowerThan = 1000;
          slowLogMaxLen = 1000;
          syslog = true;
          unixSocket = "/run/redis-blocky/redis.sock";
          unixSocketPerm = 660;
          user = "redis-blocky";
        };
      };
    };
  };
}
