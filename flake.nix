{
  description = "nixos generic flake";
  inputs = {
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
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/chronyPublic.nix
          ./server/atuin.nix
          {networking.hostName = "nixos-mp";}
        ];
      };
      nixos-mp-infra = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/chronyPublic.nix
          ./network/admin.nix
          ./server/unifi.nix
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
              hostName = "nixos-mp-infra";
              interfaces = {
                "eth0".ipv4.addresses = [
                  {
                    address = "192.168.0.250";
                    prefixLength = 24;
                  }
                ];
                "infra".ipv4.addresses = [
                  {
                    address = "10.0.0.100";
                    prefixLength = 24;
                  }
                ];
                "admin".ipv4.addresses = [
                  {
                    address = "10.0.4.100";
                    prefixLength = 24;
                  }
                ];
                "intranet".ipv4.addresses = [
                  {
                    address = "192.168.8.100";
                    prefixLength = 24;
                  }
                ];
                "iot".ipv4.addresses = [
                  {
                    address = "192.168.9.100";
                    prefixLength = 24;
                  }
                ];
              };
            };
          }
        ];
      };
    };
  };
}
