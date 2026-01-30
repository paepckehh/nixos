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
      gping
      netscanner
      stress
      tcping-go
      termshark
      trippy
      tshark
      wireguard-tools
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
