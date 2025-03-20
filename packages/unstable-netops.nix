{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs.unstable; [
      arp-scan-rs
      asn
      bandwhich
      dnstracer
      gping
      netscanner
      stress
      tcping-go
      termshark
      trippy
      tshark
    ];
  };
  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    iftop.enable = true;
    wireshark.enable = true;
  };
}
