{config, ...}: {
  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [
      "ntppool1.time.nl"
      "ntppool2.time.nl"
      "nts.netnod.se"
    ];
  };
}
