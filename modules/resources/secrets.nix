let
  age = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvG7XOtIqjA+zibUaFj9gz/zOKYkZ9gAuYmkHjbseCk age@paepcke.de";
  srv-mp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOrnlrFwXPb2H3MR5TNilQpJSjUbeFAANSPlOvSFd8kM root@srv";
in {
  "vault.age".publicKeys = [age srv-mp]; # ENV ADMIN_TOKEN="..."
  "davis.age".publicKeys = [age srv-mp];
  "miniflux.age".publicKeys = [age srv-mp]; # ENV ADMIN_USERNAME="..." ADMIN_PASSWORD="..."
  "coturn.age".publicKeys = [age srv-mp];
  "authelia-storagekey.age".publicKeys = [age srv-mp];
  "authelia-jwt.age".publicKeys = [age srv-mp];
  "authelia-session.age".publicKeys = [age srv-mp];
  "authelia-oidc-hmac.age".publicKeys = [age srv-mp];
  "authelia-oidc-issuer.age".publicKeys = [age srv-mp];
  "mkcertweb.age".publicKeys = [age srv-mp];
  "vaultls.age".publicKeys = [age srv-mp];
  "matrix.age".publicKeys = [age srv-mp];
  "zammad-db.age".publicKeys = [age srv-mp];
  "zammad-key.age".publicKeys = [age srv-mp];
  "snipeit.age".publicKeys = [age srv-mp];
  "paperless.age".publicKeys = [age srv-mp];
  "bind.age".publicKeys = [age srv-mp];
  "davis-app.age".publicKeys = [age srv-mp];
  "lldap-admin.age".publicKeys = [age srv-mp];
  "lldap-jwt.age".publicKeys = [age srv-mp];
  "lldap-seed.age".publicKeys = [age srv-mp];
  "lldap-key.age".publicKeys = [age srv-mp];
  "pki-pwd.age".publicKeys = [age srv-mp];
  "nextcloud-admin.age".publicKeys = [age srv-mp];
  "readeck.age".publicKeys = [age srv-mp];
  "onlyoffice-jwt.age".publicKeys = [age srv-mp];
  "onlyoffice-nonce.age".publicKeys = [age srv-mp];
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
