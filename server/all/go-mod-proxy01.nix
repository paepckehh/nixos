# go-mod-proxy01
{
  config,
  pkgs,
  lib,
  infra,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.go-mod-proxy01.ip} ${infra.go-mod-proxy01.hostname} ${infra.go-mod-proxy01.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.go-mod-proxy01.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.go-mod-proxy01.fqdn}" = {
      serverAliases = ["goproxy.${infra.domain.user}"];
      listenAddresses = [infra.go-mod-proxy01.ip];
      extraConfig = ''import intraproxy ${toString infra.go-mod-proxy01.localbind.port.http}'';
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.go-mod-proxy01 = {
    description = "goproxy caching Go module proxy";
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    startLimitIntervalSec = 30;
    startLimitBurst = 3;
    environment = {
      BIND_ADDR = "${infra.localhost.ip}:${toString infra.go-mod-proxy01.localbind.port.http}";
      CACHE_ROOT = "/nix/persist/cache/go/proxy";
      NEIGHBOUR_CACHES = infra.go-mod-proxy02.url;
    };
    serviceConfig = {
      ExecStart = "/nix/persist/root/bin/goproxy";
      StateDirectory = "goproxy";
      Type = "exec";
      Restart = "always";
      RestartSec = "2s";
      TimeoutStopSec = "15s";
      UMask = "0077";
      MemoryMax = "512M";
      TasksMax = 512;
      LimitNOFILE = 16384;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ReadWritePaths = ["/var/lib/goproxy" "/nix/persist/cache/go/proxy"];
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      KeyringMode = "private";
      LockPersonality = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RestrictNamespaces = true;
      MemoryDenyWriteExecute = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@aio"
        "~@keyring"
        "~@memlock"
        "~@setuid"
        "~@timer"
      ];
      CapabilityBoundingSet = "";
      RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      SocketBindDeny = "any";
      SocketBindAllow = "tcp:${toString infra.go-mod-proxy01.localbind.port.http}";
    };
  };
}
