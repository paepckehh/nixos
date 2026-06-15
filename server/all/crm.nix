{
  config,
  pkgs,
  lib,
  ...
}: {
  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      crm.extraGroups = ["crm"];
      crm = {
        createHome = true;
        description = "crm service account";
        uid = 6969;
        isSystemUser = true;
        group = "crm";
        home = "/var/lib/crm";
      };
    };
    groups."crm" = {
      name = "crm";
      members = ["crm"];
      gid = 6969;
    };
  };
  
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.contact.ip} ${infra.contact.hostname} ${infra.contact.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [
    {Address = "${infra.auftraggeber.ip}/32";}
    {Address = "${infra.agent.ip}/32";}
    {Address = "${infra.contact.ip}/32";}
  ];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts = {
      "${infra.auftraggeber.fqdn}" = {
         listenAddresses = [infra.auftraggeber.ip];
         extraConfig = ''import intraproxy ${toString infra.auftraggeber.localbind.port.http}'';
    };
      "${infra.agent.fqdn}" = {
         listenAddresses = [infra.agent.ip];
         extraConfig = ''import intraauthproxy ${toString infra.auftraggeber.agent.port.http}'';
    };
      "${infra.contact.fqdn}" = {
         listenAddresses = [infra.contact.ip];
         extraConfig = ''import intraauthproxy ${toString infra.auftraggeber.contact.port.http}'';
    };
  };
};

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    services.crm = {
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      description = "CRM Service";
      serviceConfig = {
        ExecStart = "/root/bin/crm";
        KillMode = "process";
        Restart = "always";
        PreStart = "cd /var/lib/crm";
        User = "crm";
        StateDirectory = "crm";
        StateDirectoryMode = "0750";
        WorkingDirectory = "/var/lib/crm";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
      };
      environment = {
        CRM_PORT_WEBAPP_01 = "${toString infra.auftraggeber.localbind.port.http}";
        CRM_PORT_WEBAPP_02 = "${toString infra.agent.localbind.port.http}";
        CRM_PORT_WEBAPP_03 = "${toString infra.contact.localbind.port.http}";
      };
    };
  };
}
