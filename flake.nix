{
  description = "nixos infra";
  inputs = {
    nixpkgs-release.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    disko,
    nixpkgs,
    nixpkgs-release,
    home-manager,
  }: {
    nixosConfigurations = {
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations.nixos;
        modules = [
          ./modules/iso-autoinstaller.nix
        ];
      };
      nixos = nixpkgs-release.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./modules/disko.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          ./server/adguard.nix
          ./server/chronyPublic.nix
          {networking.hostName = "nixos";}
        ];
      };
      nixos-mp = nixpkgs-Release.lib.nixosSystem {
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
      nixos-infra = nixpkgs-Release.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./person/mpaepcke.nix
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/chronyPublic.nix
          ./server/unifi.nix
          ./server/ollama.nix
          ./server/openweb-ui.nix
          ./server/virtual.nix
          # ./server/firefox-sync-server.nix
          # ./server/gitea.nix
          # ./server/opnborg.nix
          # ./server/opnborg-complex.nix
          # ./server/opnborg-docker-complex.nix
          # ./server/webserver-nginx.nix
          {networking.hostName = "nixos-infra";}
        ];
      };
      nixos-mp-infra = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./person/mpaepcke_luks.nix # XXX
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/chronyPublic.nix
          ./server/ollama.nix
          ./server/openweb-ui.nix
          ./server/unifi.nix
          ./server/virtual.nix
          # ./server/firefox-sync-server.nix
          # ./server/gitea.nix
          # ./server/opnborg.nix
          # ./server/opnborg-complex.nix
          # ./server/opnborg-docker-complex.nix
          # ./server/webserver-nginx.nix
          {networking.hostName = "nixos-mp-infra";}
        ];
      };
    };
  };
}
