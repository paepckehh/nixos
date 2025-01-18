{
  description = "nixos infra";
  inputs = {
    # ONLINE URLs
    disko.url = "github:nix-community/disko/master";
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # GLOBAL
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    disko,
    home-manager,
    nixpkgs,
    nixpkgs-unstable,
  }: let
    # GLOBAL
    nix-iso-target-hostname = "nixos";
    overlay-unstable = final: prev: {unstable = nixpkgs-unstable.legacyPackages.${prev.system};};
  in {
    nixosConfigurations = {
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations.${nix-iso-target-hostname};
        modules = [
          ./modules/iso-autoinstaller.nix
        ];
      };
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./role/client-desktop.nix
          ./user/desktop/me.nix
          {networking.hostName = "nixos";}
        ];
      };
      nixos-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./role/client-desktop.nix
          ./person/desktop/mpaepcke.nix
          {networking.hostName = "nixos-mp";}
        ];
      };
      nixos-srv = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./role/client-desktop.nix
          ./person/mpaepcke.nix
          ./person/desktop/mpaepcke.nix
          ./server/virtual.nix
          {networking.hostName = "nixos-srv";}
        ];
      };
      nixos-srv-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({
            config,
            pkgs,
            ...
          }: {nixpkgs.overlays = [overlay-unstable];})
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./role/client-desktop.nix
          ./person/mpaepcke_luks.nix
          ./person/desktop/mpaepcke.nix
          ./hosts/nixos-srv-mp.nix
          # ./modules/wg-client-adm.nix
          # ./server/virtual.nix
          # ./server/unifi.nix
          # ./server/opnborg-systemd.nix
          # ./server/cgit.nix
          # ./server/firefox-sync-server.nix
          # ./server/gitea.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          # ./server/opnborg.nix
          # ./server/opnborg-complex.nix
          # ./server/opnborg-docker-complex.nix
          # ./server/webserver-nginx.nix
        ];
      };
    };
  };
}
