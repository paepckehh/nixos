{
  lib,
  infra,
  ...
}: {
  imports = [
    (import ../../lib/proxy.nix {
      inherit infra;
      name = "res";
      caddy = ''
        import intra
        root * /var/lib/caddy/res
        file_server browse
      '';
    })
  ];
}
