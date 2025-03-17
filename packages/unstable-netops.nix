{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs.unstable; [
      asn
      # arp-scanner-rs
      dnstracer
      netscanner
      stress
      tcping-go
      termshark
      tshark
    ];
  };
}
