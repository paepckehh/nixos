let
  mpaepcke = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIA44D5TOInaQRb7DrUzMVOciR3kdXhQK9ghkjaZiZJAFAAAABHNzaDo= git@paepcke.de";
  age = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvG7XOtIqjA+zibUaFj9gz/zOKYkZ9gAuYmkHjbseCk age@paepcke.de";
  users = [age];

  srv-mp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArbsQC2gdtQ9qCC54Khfei/rVMtVjOTiS0sduAi4jDO root@srv-mp";
  hosts = [srv-mp];
in {
  "tibber.age".publicKeys = [age];
  "ecoflow_email.age".publicKeys = [age];
  "ecoflow_password.age".publicKeys = [age];
  "ecoflow_access_key.age".publicKeys = [age];
  "ecoflow_access_secret.age".publicKeys = [age];
}
