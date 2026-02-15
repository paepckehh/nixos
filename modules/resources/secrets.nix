let
  srv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN95PYUMGYuzc+gsuxZ76p5eT2nocV8ckGUQtQ7T4Mn1 srv";
in {
  "it.age".publicKeys = [srv];
  "ti.age".publicKeys = [srv];
  "fa.age".publicKeys = [srv];
  "vault.age".publicKeys = [srv]; # ENV ADMIN_TOKEN="..."
  "davis.age".publicKeys = [srv];
  "ncps.age".publicKeys = [srv];
  "me.age".publicKeys = [srv];
  "miniflux.age".publicKeys = [srv]; # ENV ADMIN_USERNAME="..." ADMIN_PASSWORD="..."
  "coturn.age".publicKeys = [srv];
  "coturn-matrix.age".publicKeys = [srv];
  "authelia-storagekey.age".publicKeys = [srv];
  "authelia-jwt.age".publicKeys = [srv];
  "authelia-session.age".publicKeys = [srv];
  "authelia-oidc-hmac.age".publicKeys = [srv];
  "authelia-oidc-issuer.age".publicKeys = [srv];
  "mkcertweb.age".publicKeys = [srv];
  "vaultls.age".publicKeys = [srv];
  "matrix.age".publicKeys = [srv];
  "zammad-db.age".publicKeys = [srv];
  "zammad-key.age".publicKeys = [srv];
  "snipeit.age".publicKeys = [srv];
  "paperless.age".publicKeys = [srv];
  "bind.age".publicKeys = [srv];
  "davis-app.age".publicKeys = [srv];
  "lldap-admin.age".publicKeys = [srv];
  "lldap-jwt.age".publicKeys = [srv];
  "lldap-seed.age".publicKeys = [srv];
  "lldap-key.age".publicKeys = [srv];
  "pki-pwd.age".publicKeys = [srv];
  "nextcloud-admin.age".publicKeys = [srv];
  "readeck.age".publicKeys = [srv];
  "onlyoffice-jwt.age".publicKeys = [srv];
  "onlyoffice-nonce.age".publicKeys = [srv];
  "wg-nix-pk-wg110.age".publicKeys = [srv];
  "wg-nix-pk-wg100.age".publicKeys = [srv];
  "wg-nix-psk.age".publicKeys = [srv];
  "duck.age".publicKeys = [srv];
  "tibber.age".publicKeys = [srv];
  "syslog-ng-key.age".publicKeys = [srv];
  "openwrt-admin-pwd.age".publicKeys = [srv];
  "zitadel-key.age".publicKeys = [srv];
  "zitadel-tls-key.age".publicKeys = [srv];
  "zitadel-tls-cert.age".publicKeys = [srv];
  "ecoflow-access-key.age".publicKeys = [srv];
  "ecoflow-secret-key.age".publicKeys = [srv];
  "ecoflow-email.age".publicKeys = [srv];
  "ecoflow-password.age".publicKeys = [srv];
  "ecoflow-devices.age".publicKeys = [srv];
}
