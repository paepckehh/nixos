{lib, ...}: {
  ###############
  # ENVIRONMENT #
  ###############
  environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ed6058";

  ##############
  # NETWORKING #
  ##############
  networking = {
    hostName = "srv";
    usePredictableInterfaceNames = lib.mkForce true;
  };

  ###########
  # SYSTEMD #
  ###########
  systemd.network.networks = {
    "00-corp" = {
      enable = true;
      addresses = [
        {Address = "192.168.80.100/24";}
        {Address = "10.20.0.100/24";}
        {Address = "10.20.1.100/23";}
        {Address = "10.20.3.100/23";}
        {Address = "10.20.5.100/23";}
      ];
      domains = ["corp" "adm.corp" "sec.corp" "srv.corp" "dbt.corp"];
      dns = ["192.168.80.1"];
      gateway = ["192.168.80.1"];
      ntp = ["192.168.80.1"];
      matchConfig.Name = "enp1s0f4u2u1";
      linkConfig.ActivationPolicy = "always-up";
    };
  };
}
