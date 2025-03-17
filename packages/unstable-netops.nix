{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs.unstable; [
      asn
      arp-scanner
      dnstracer
      netscanner
      stress
      tcping-go
      termshark
      tshark
    ];
  };
}
