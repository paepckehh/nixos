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
          ./desktop/gnome.nix
          ./person/mpaepcke_luks.nix
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/chronyPublic.nix
          ./server/unifi.nix
          # ./server/virtual.nix
          # ./modules/autoupdate.nix
          # ./server/send.nix
          # ./server/firefox-sync-server.nix
          # ./server/prometheus.nix
          # ./server/rsync.nix
          # ./server/wg-easy.nix
          # ./server/wg-acccess-server.nix
          # ./server/gitea.nix
          # ./server/opnborg.nix
          # ./server/opnborg-complex.nix
          # ./server/opnborg-docker-complex.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          # ./server/webserver-nginx.nix
          # ./server/wiki.nix

          {
            networking = {
              hostName = "nixos-mp-infra";
              domain = "infra.lan";
              search = ["infra.lan" "client.home.lan" "iot.home.lan" "server.home.lan" "admin.lan" "infra.lan" "lan"];
              nameservers = ["10.0.0.3" "10.0.0.2"];
              timeServers = ["10.0.0.3" "10.0.0.2"];
              enableIPv6 = false;
              useDHCP = false;
              usePredictableInterfaceNames = false;
              networkmanager.enable = nixpkgs.lib.mkForce false;
              wireless.enable = false;
              defaultGateway = {
                address = "192.168.8.1"; # legacy
                interface = "setup";
              };
              resolvconf = {
                enable = true;
                useLocalResolver = false;
              };
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
                "setup".ipv4.addresses = [
                  {
                    address = "192.168.8.2"; # legacy
                    prefixLength = 24;
                  }
                ];
                "admin".ipv4.addresses = [
                  {
                    address = "10.0.8.2";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.8.3";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.8.30";
                    prefixLength = 24;
                  }
                ];
                "server".ipv4.addresses = [
                  {
                    address = "10.0.16.2";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.16.3";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.16.30";
                    prefixLength = 24;
                  }
                ];
                "client".ipv4.addresses = [
                  {
                    address = "10.0.128.2";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.128.3";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.128.30";
                    prefixLength = 24;
                  }
                ];
                "iot".ipv4.addresses = [
                  {
                    address = "10.0.250.2";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.250.3";
                    prefixLength = 32;
                  }
                  {
                    address = "10.0.250.30";
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
