{
  description = "nixos generic flake";
  inputs = {
    # nixpkgs.url = "github:paepckehh/nixpkgs/wg-access-server-fix";
    # nixpkgs.url = "github:paepckehh/nixpkgs/opnborg-service";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
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
      ###############
      # NIXOS HOSTS #
      ###############
      nixos-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./modules/chronyPublic.nix
          ./desktop/gnome.nix
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          # ./hardware/macbook-intel.nix
          # ./server/netbird.nix
          # ./server/unifi.nix
          # ./server/prometheus.nix
          # ./server/virtual.nix
          # ./modules/autoupdate.nix
          # ./modules/localinfra.nix
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
          ./server/ollama.nix
          ./server/openweb-ui.nix
          # ./server/mopidy.nix
          # ./server/uptime.nix
          # ./server/yopass-ng.nix
          # ./server/webserver-nginx.nix
          # ./server/wiki.nix
          {networking.hostName = "nixos-mp";}
        ];
      };
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hardware/nvidia-off.nix
          ./modules/chronyPublic.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          ./server/adguard.nix
          {networking.hostName = "nixos";}
        ];
      };
      nixos-console = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hardware/nvidia-off.nix
          ./modules/chronyPublic.nix
          ./server/adguard.nix
          ./user/me.nix
          {networking.hostName = "nixos-console";}
        ];
      };
      nixbuilder = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hardware/nvidia-off.nix
          ./modules/chronyPublic.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          ./server/adguard.nix
          ./server/rsync.nix
          # ./server/builder.nix
          # ./server/virtual.nix
          # ./server/docker.nix
          # ./server/gitea.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          {networking.hostName = "nixbuilder";}
        ];
      };
    };
  };
}
