# winupdate winupdate.dat
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
  networking.extraHosts = "${infra.winupdate.ip} ${infra.winupdate.hostname} ${infra.winupdate.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.winupdate.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.winupdate.fqdn}" = {
      listenAddresses = ["${infra.winupdate.ip}:${toString infra.port.https}"];
      extraConfig = ''
        import intra
        header {
                Content-Type text/csv
                Serial-Number 111
                Body-SHA224  4fcf5c4f4b239cba2fd3dc22cfb09cce0659236c5f00c9432c488770
                SHA224-Signature AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAGsgOTEwxqUCKC49pwuQHXyhb+jjIBUzFdwRsjS9iMkAAAABHNzaDo=
        }
        respond <<HTML
        "C:\Windows\PortableAPPs\Wazuh.exe","b57c142d1017234c2894193c27af3edd57a8d6995b17506643a8c99a","${infra.res.url}/win/Wazuh.exe"
        "C:\Windows\PortableAPPs\Librewolf.exe","7f79d4c74dddc66242f1ffdbd591f0a591708ac1c940a0929a2b9604","${infra.res.url}/win/Librewolf.exe"
        "C:\Windows\PortableAPPs\OnlyOffice.exe","b34bbe1850a1d3b102e7fccbbb93a4e6239367fcfc6fb8d4576ea58a","${infra.res.url}/win/OnlyOffice.exe"
        HTML 200
      '';
    };
  };
}
