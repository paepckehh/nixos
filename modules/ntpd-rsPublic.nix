{config, ...}: {
  services.ntpd-rs = {
    enable = true;
    metrics.enable = true;
    useNetworkingTimeServers = false;
    settings = ''
      [[source]]
       mode="nts"
       address="ntppool1.time.nl"'';
  };
}
