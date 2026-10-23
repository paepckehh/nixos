# build the systemd network and caddy based reverse proxy infra
{
  name,
  ns ? "user",
  caddy ? null,
  ...
}: let
  infra = (import ../siteconfig/config.nix).infra;
  s = infra.${name};
  defaultCaddy = "import intraproxy ${toString s.localbind.port.http}";
in {
  networking.extraHosts = "${s.ip} ${s.hostname} ${s.fqdn}";
  systemd.network.networks."${infra.namespace.${ns}}".addresses = [{Address = "${s.ip}/32";}];
  services.caddy.virtualHosts."${s.fqdn}" = {
    listenAddresses = [s.ip];
    extraConfig =
      if caddy != null
      then caddy
      else defaultCaddy;
  };
}
