{pkgs, ...}: {
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [
      arp-scan
      asn
      bandwhich
      dnstracer
      dhcping
      gping
      grepcidr
      netscanner
      ngrep
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
