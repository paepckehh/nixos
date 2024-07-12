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
      "paris.time.system76.com"
      "brazil.time.system76.com"
      "ohio.time.system76.com"
      "oregon.time.system76.com"
      "virginia.time.system76.com"
      "stratum1.time.cifelli.xyz"
      "time.txryan.com"
    ];
  };
}
