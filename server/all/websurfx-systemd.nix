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
  #-=# ENVIROMENT #=-#
  ####################
  environment.systemPackages = [pkgs.websurfx];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.websurfx.ip} ${infra.websurfx.hostname} ${infra.websurfx.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.websurfx.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.websurfx.fqdn}" = {
      listenAddresses = [infra.websurfx.ip];
      extraConfig = ''import intraproxy 8080'';
      # extraConfig = ''import intraproxy ${toString infra.websurfx.localbind.port.http}'';
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services.websurfx = {
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    description = "Websurfx Service";
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${lib.getExe pkgs.websurfx}";
      KillMode = "process";
      Restart = "always";
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      LockPersonality = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RuntimeDirectory = "websurfx";
      StateDirectory = "websurfx";
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "@chown"
        "~@aio"
        "~@keyring"
        "~@memlock"
        "~@setuid"
        "~@timer"
      ];
    };
  };
}
