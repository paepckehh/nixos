{
  config,
  lib,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    prometheus.exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = [
        "logind"
        "systemd"
        "wireguard"
      ];
      disabledCollectors = [];
      openFirewall = true;
      # firewallFilter = "-i br0 -p tcp -m tcp --dport 9100";
    };
  };
}
