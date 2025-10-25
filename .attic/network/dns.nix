{dns, ...}:
with dns.lib.combinators; {
  SOA = {
    nameServer = "ns1.lan";
    adminEmail = "abuse@paepcke.de";
    serial = 202505271047;
  };
  useOrigin = false;
  NS = ["ns1.lan."];
  A = ["192.168.80.200"];
  CAA = letsEncrypt "abuse@paepcke.de";
  subdomains = {
    ns1 = host "192.168.80.1";
    axt = host "192.168.80.1";
    read = host "192.168.80.200";
    atuin = host "192.168.80.201";
  };
}
