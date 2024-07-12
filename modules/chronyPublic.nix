{config, ...}: {
  services.chrony = {
    enable = true;
    enableNTS = true;
    enableMemoryLocking = true;
    servers = [
      "ntppool1.time.nl"
      "ntppool2.time.nl"
      "ntp.3eck.net"
      "ntp.trifence.ch"
      "ntp.zeitgitter.net"
      "mmo1.nts.netnod.se"
      "mmo2.nts.netnod.se"
      "sth1.nts.netnod.se"
      "sth2.nts.netnod.se"
      "svl1.nts.netnod.se"
      "svl2.nts.netnod.se"
      "paris.time.system76.com"
    ];
  };
}
