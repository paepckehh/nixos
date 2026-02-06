let
  age = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvG7XOtIqjA+zibUaFj9gz/zOKYkZ9gAuYmkHjbseCk age@paepcke.de";
  srv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN95PYUMGYuzc+gsuxZ76p5eT2nocV8ckGUQtQ7T4Mn1 srv";
in {
  "vault.age".publicKeys = [age srv]; # ENV ADMIN_TOKEN="..."
  "davis.age".publicKeys = [age srv];
  "me.age".publicKeys = [age srv];
  "miniflux.age".publicKeys = [age srv]; # ENV ADMIN_USERNAME="..." ADMIN_PASSWORD="..."
  "coturn.age".publicKeys = [age srv];
  "coturn-matrix.age".publicKeys = [age srv];
  "authelia-storagekey.age".publicKeys = [age srv];
  "authelia-jwt.age".publicKeys = [age srv];
  "authelia-session.age".publicKeys = [age srv];
  "authelia-oidc-hmac.age".publicKeys = [age srv];
  "authelia-oidc-issuer.age".publicKeys = [age srv];
  "mkcertweb.age".publicKeys = [age srv];
  "vaultls.age".publicKeys = [age srv];
  "matrix.age".publicKeys = [age srv];
  "zammad-db.age".publicKeys = [age srv];
  "zammad-key.age".publicKeys = [age srv];
  "snipeit.age".publicKeys = [age srv];
  "paperless.age".publicKeys = [age srv];
  "bind.age".publicKeys = [age srv];
  "davis-app.age".publicKeys = [age srv];
  "lldap-admin.age".publicKeys = [age srv];
  "lldap-jwt.age".publicKeys = [age srv];
  "lldap-seed.age".publicKeys = [age srv];
  "lldap-key.age".publicKeys = [age srv];
  "pki-pwd.age".publicKeys = [age srv];
  "nextcloud-admin.age".publicKeys = [age srv];
  "readeck.age".publicKeys = [age srv];
  "onlyoffice-jwt.age".publicKeys = [age srv];
  "onlyoffice-nonce.age".publicKeys = [age srv];
  "wg-nix-pk-wg110.age".publicKeys = [age srv];
  "wg-nix-pk-wg100.age".publicKeys = [age srv];
  "wg-nix-psk.age".publicKeys = [age srv];
  "duck.age".publicKeys = [age srv];
  "tibber.age".publicKeys = [age srv];
  "syslog-ng-key.age".publicKeys = [age srv];
  "openwrt-admin-pwd.age".publicKeys = [age srv];
  "zitadel-key.age".publicKeys = [age srv];
  "zitadel-tls-key.age".publicKeys = [age srv];
  "zitadel-tls-cert.age".publicKeys = [age srv];
  "ecoflow-access-key.age".publicKeys = [age srv];
  "ecoflow-secret-key.age".publicKeys = [age srv];
  "ecoflow-email.age".publicKeys = [age srv];
  "ecoflow-password.age".publicKeys = [age srv];
  "ecoflow-devices.age".publicKeys = [age srv];
}
