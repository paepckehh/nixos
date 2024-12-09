{
  description = "nixos generic flake";
  inputs = {
    # nixpkgs.url = "github:paepckehh/nixpkgs/master";
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
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          ./server/adguard.nix
          ./server/chronyPublic.nix
          {networking.hostName = "nixos-mp";}
        ];
      };
      nixos-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/chronyPublic.nix
          {networking.hostName = "nixos-mp";}
        ];
      };
      nixos-mp-infra = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./network/admin.nix
          ./desktop/gnome.nix
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/chronyPublic.nix
          ./server/unifi.nix
          # ./server/virtual.nix
          # ./server/firefox-sync-server.nix
          # ./infra/local.nix
          # ./modules/autoupdate.nix
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
                    address = "10.0.0.2";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.0.3";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.0.30";
                    prefixLength = 24;
                  }
                ];
                "admin".ipv4.addresses = [
                  {
                    address = "10.0.4.2";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.4.3";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.4.30";
                    prefixLength = 24;
                  }
                ];
                "intranet".ipv4.addresses = [
                  {
                    address = "10.0.8.2";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.8.3";
                    prefixLength = 32;
                  }
                  {
                    address = "192.168.8.30";
                    prefixLength = 24;
                  }
                ];
                "iot".ipv4.addresses = [
                  {
                    address = "10.0.9.2";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.9.3";
                    prefixLength = 32;
                  }
                  {
                    address = "192.168.9.30";
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
