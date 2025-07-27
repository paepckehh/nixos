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
      nmap
      stress
      tcping-go
      termshark
      trippy
      tshark
      wireguard-tools
      zmap
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
