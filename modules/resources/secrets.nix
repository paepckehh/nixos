let
  age = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvG7XOtIqjA+zibUaFj9gz/zOKYkZ9gAuYmkHjbseCk age@paepcke.de";
  srv-mp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArbsQC2gdtQ9qCC54Khfei/rVMtVjOTiS0sduAi4jDO root@srv-mp";
in {
  "davis.age".publicKeys = [age srv-mp];
  "davis-app.age".publicKeys = [age srv-mp];
  "lldap-admin.age".publicKeys = [age srv-mp];
  "lldap-jwt.age".publicKeys = [age srv-mp];
  "lldap-seed.age".publicKeys = [age srv-mp];
  "lldap-key.age".publicKeys = [age srv-mp];
  "pki-pwd.age".publicKeys = [age srv-mp];
  "nextcloud-admin.age".publicKeys = [age srv-mp];
  "readeck.age".publicKeys = [age srv-mp];
  "wg-nix-pk-wg110.age".publicKeys = [age srv-mp];
  "wg-nix-pk-wg100.age".publicKeys = [age srv-mp];
  "wg-nix-psk.age".publicKeys = [age srv-mp];
  "duck.age".publicKeys = [age srv-mp];
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
