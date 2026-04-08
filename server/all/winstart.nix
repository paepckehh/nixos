# winstart winstart.dat
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.winstart.ip} ${infra.winstart.hostname} ${infra.winstart.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.winstart.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.winstart.fqdn}" = {
      listenAddresses = ["${infra.winstart.ip}:${toString infra.port.https}"];
      extraConfig = ''
        import intra
        header {
                Content-Type text/plain
                Serial-Number 110
                Body-SHA224  4fcf5c4f4b239cba2fd3dc22cfb09cce0659236c5f00c9432c488770
                SHA224-Signature AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAGsgOTEwxqUCKC49pwuQHXyhb+jjIBUzFdwRsjS9iMkAAAABHNzaDo=
        }
        respond <<HTML
        #110
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 255 /f
        w32tm /register
        w32tm /config /manualpeerlist:"10.20.6.3, 10.20.6.2, 10.20.6.11, 10.20.6.12, 10.20.6.13"
        w32tm /config /syncfromflags:manual
        w32tm /config /update
        HTML 200
      '';
    };
  };
}
