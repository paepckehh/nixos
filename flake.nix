{
  description = "nixos generic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
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
          ./hardware/macbook-intel.nix
          ./modules/chronyPublic.nix
          ./desktop/gnome.nix
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/virtual.nix
          # ./modules/autoupdate.nix
          # ./server/sync.nix
          # ./server/gitea.nix
          # ./server/opnborg-complex.nix
          # ./server/opnborg-docker.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          # ./server/uptime.nix
          # ./server/unifi.nix
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
          ./server/builder.nix
          ./server/docker.nix
          ./server/virtual.nix
          # ./server/adguard.nix
          # ./server/gitea.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          {networking.hostName = "nixbuilder";}
        ];
      };
    };
  };
}
