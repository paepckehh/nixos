let
  age = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvG7XOtIqjA+zibUaFj9gz/zOKYkZ9gAuYmkHjbseCk age@paepcke.de";
  srv-mp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArbsQC2gdtQ9qCC54Khfei/rVMtVjOTiS0sduAi4jDO root@srv-mp";
in {
  "ssh_host_ed25519_key_srv.age".publicKeys = [age srv-mp];
  "ssh_yubikey_mp.age".publicKeys = [age srv-mp];
  "tibber.age".publicKeys = [age srv-mp];
  "syslog-ng-key.age".publicKeys = [age srv-mp];
  "openwrt-admin-pwd.age".publicKeys = [age srv-mp];
  "zitadel-key.age".publicKeys = [age srv-mp];
  "zitadel-tls-key.age".publicKeys = [age srv-mp];
  "zitadel-tls-cert.age".publicKeys = [age srv-mp];
  "ecoflow-access-key.age".publicKeys = [age srv-mp];
  "ecoflow-secret-key.age".publicKeys = [age srv-mp];
  "ecoflow-email.age".publicKeys = [age srv-mp];
  "ecoflow-password.age".publicKeys = [age srv-mp];
  "ecoflow-devices.age".publicKeys = [age srv-mp];
}
