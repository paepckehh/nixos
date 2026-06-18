# crush, cloud
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
  networking.extraHosts = "${infra.crush.ip} ${infra.crush.hostname} ${infra.crush.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.crush.ip}/32";}];

  ####################
  #-=# CONTAINERS #=-#
  ####################
  containers.crush = {
    autoStart = true;
    privateNetwork = false;
    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      #################
      #-=# IMPORTS #=-#
      #################
      imports = [
        ../../client/env.nix
        ../../user/me.nix
      ];

      ####################
      #-=# NETWORKING #=-#
      ####################
      networking.hostName = infra.crush.hostname;

      #####################
      #-=# ENVIRONMENT #=-#
      #####################
      environment = {
        systemPackages = with pkgs; [ 
          tsshd
          crush
        ];
        etc."ssh/sshd_config".text = "...";
      };

      #################
      #-=# SYSTEMD #=-#
      #################
      systemd = {
        services.tsshd = {
          after = ["network.target"];
          wantedBy = ["multi-user.target"];
          description = "modern resumeable sshd replacement";
          serviceConfig = {
            ExecStart = "${pkgs.tsshd}/bin/tsshd";
            KillMode = "process";
            Restart = "always";
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
              "AF_UNIX"
            ];
          };
        };
      };
    };
  };
}
