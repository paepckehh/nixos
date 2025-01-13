{
  description = "nixos infra";
  inputs = {
    # ONLINE
    nixpkgs-release.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko.url = "github:nix-community/disko/master";
    home-manager.url = "github:nix-community/home-manager/master";
    #
    # OFFLINE
    # nixpkgs-release.url = "http://git.localnet/nixos/nixpkgs";
    # disko.url = "http://git.localnet/nix-community/disko";
    # home-manager.url = "http://git.localnet/nix-community/home-manager";
    #
    # CONFIG
    disko.inputs.nixpkgs.follows = "nixpkgs-release";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-release";
  };
  outputs = {
    self,
    disko,
    nixpkgs-release,
    home-manager,
  }: {
    nixosConfigurations = {
      iso = nixpkgs-release.lib.nixosSystem {
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
          ./modules/disko.nix
          ./configuration.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          ./server/adguard.nix
          ./server/cgit.nix
          ./server/chronyPublic.nix
          {networking.hostName = "nixos";}
        ];
      };
      nixos-mp = nixpkgs-release.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./modules/disko.nix
          ./configuration.nix
          ./desktop/gnome.nix
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/cgit.nix
          ./server/chronyPublic.nix
          {networking.hostName = "nixos-mp";}
        ];
      };
      nixos-srv = nixpkgs-release.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./modules/disko.nix
          ./configuration.nix
          ./desktop/gnome.nix
          ./person/mpaepcke.nix
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/cgit.nix
          ./server/chronyPublic.nix
          ./server/virtual.nix
          # ./server/unifi.nix
          # ./server/firefox-sync-server.nix
          # ./server/gitea.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          # ./server/opnborg.nix
          # ./server/opnborg-complex.nix
          # ./server/opnborg-docker-complex.nix
          # ./server/webserver-nginx.nix
          {networking.hostName = "nixos-srv";}
        ];
      };
      nixos-srv-mp = nixpkgs-release.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./modules/disko.nix
          ./configuration.nix
          ./desktop/gnome.nix
          ./person/mpaepcke_luks.nix # XXX
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/cgit.nix
          ./server/chronyPublic.nix
          ./server/virtual.nix
          # ./server/unifi.nix
          # ./server/firefox-sync-server.nix
          # ./server/gitea.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          # ./server/opnborg.nix
          # ./server/opnborg-complex.nix
          # ./server/opnborg-docker-complex.nix
          # ./server/webserver-nginx.nix
          {networking.hostName = "nixos-srv-mp";}
        ];
      };
    };
  };
}
