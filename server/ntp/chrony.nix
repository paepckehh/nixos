{
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    timesyncd.enable = false;
    chrony = {
      enable = true;
      autotrimThreshold = "30";
      servers = [
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
        "ntppool1.time.nl"
        "ntppool2.time.nl"
        "nts.netnod.se"
        "ptbtime1.ptb.de"
        "time.dfm.dk"
        "time.cifelli.xyz"
        "ntp.3eck.net"
        "ntp.zeitgitter.net"
        "paris.time.system76.com"
      ];
      enableNTS = true;
      enableRTCTrimming = true;
      enableMemoryLocking = true;
      extraConfig = ''minsources 3'';
    };
  };
}
