{config, ...}: {
  services = {
    timesyncd.enable = false;
    chrony = {
      enable = true;
      servers = [""];
      extraFlags = ["-F 1"];
      enableNTS = true;
      enableMemoryLocking = true;
      extraConfig = ''
        # cmdport 0
        server ntppool1.time.nl iburst nts
        server ntppool2.time.nl iburst nts
        server nts.netnod.se iburst nts
        server ptbtime1.ptb.de iburst nts
        server time.dfm.dk iburst nts
        server time.cifelli.xyz iburst nts
        server ntp.3eck.net iburst nts
        server ntp.trifence.ch iburst nts
        server ntp.zeitgitter.net iburst nts
        server paris.time.system76.com iburst nts 
        minsources 4
        authselectmode require
        dscp 46
        driftfile /var/lib/chrony/drift
        ntsdumpdir /var/lib/chrony
        leapsectz right/UTC
        makestep 1.0 3
        rtconutc'';
    };
  };
}
