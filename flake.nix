{
  description = "nixos generic flake";
  inputs = {
    # nixpkgs.url = "github:paepckehh/nixpkgs/wg-access-server-fix";
    # nixpkgs.url = "github:paepckehh/nixpkgs/opnborg-service";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    # nixpkgs.url = "github:NixOS/nixpkgs/3048d1e";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
  }: {
    nixosConfigurations = {
      nixos-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./modules/chronyPublic.nix
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          # ./server/unifi.nix
          # ./infra/local.nix
          # ./modules/autoupdate.nix
          # ./server/virtual.nix
          # ./server/send.nix
          # ./server/netbird.nix
          # ./server/prometheus.nix
          # ./server/pingvin.nix
          # ./server/picoshare.nix
          # ./server/shifter.nix
          # ./server/rsync.nix
          # ./server/wg-easy.nix
          # ./server/wg-acccess-server.nix
          # ./server/docker.nix
          # ./server/sync.nix
          # ./server/gitea.nix
          # ./server/opnborg.nix
          # ./server/opnborg-complex.nix
          # ./server/opnborg-docker-complex.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          # ./server/mopidy.nix
          # ./server/uptime.nix
          # ./server/yopass-ng.nix
          # ./server/webserver-nginx.nix
          # ./server/wiki.nix
          {
            networking = {
              domain = "intra.lan";
              defaultGateway = {
                address = "192.168.8.1";
                interface = "intranet";
              };
              hostName = "nixos-mp";
              interfaces = {
                "admin".ipv4.adresses = [
                  {
                    address = "10.0.0.100";
                    prefixLength = 24;
                  }
                ];
                "intranet".ipv4.addresses = [
                  {
                    address = "192.168.8.100";
                    prefixLength = 24;
                  }
                ];
              };
              search = ["intra.lan" "admin" "lan"];
              timeServers = ["127.0.0.1"];
              vlans = {
                "admin" = {
                  id = 1;
                  interface = "eth0";
                };
                "intranet" = {
                  id = 0;
                  interface = "eth0";
                };
              };
            };
          }
        ];
      };
    };
  };
}
