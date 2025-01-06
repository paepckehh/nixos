{
  description = "nixos infra";
  inputs = {
    # nixpkgs-release.url = "github:NixOS/nixpkgs/nixos-24.11";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # disko = {
    #   url = "github:nix-community/disko/master";
    #   inputs.nixpkgs.follows = "nixpkgs-release";
    # };
    # home-manager = {
    #   url = "github:nix-community/home-manager/master";
    #   inputs.nixpkgs.follows = "nixpkgs-release";
    # };
    nixpkgs-release.url  = "path:/home/me/dev/nixpkgs";
    nixpkgs-unstable.url = "path:/home/me/dev/nixpkgs";
    disko = {
      url = "path:/home/me/dev/disko";
      inputs.nixpkgs.follows = "nixpkgs-release";
    };
    home-manager = {
      url = "path:/home/me/dev/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-release";
    };
  };
  outputs = {
    self,
    disko,
    nixpkgs-release,
    nixpkgs-unstable,
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
          ./server/chronyPublic.nix
          {networking.hostName = "nixos";}
        ];
      };
      nixos-mp = nixpkgs-release.lib.nixosSystem {
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
      nixos-infra = nixpkgs-release.lib.nixosSystem {
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
          ./server/virtual.nix
          # ./server/firefox-sync-server.nix
          # ./server/gitea.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          # ./server/opnborg.nix
          # ./server/opnborg-complex.nix
          # ./server/opnborg-docker-complex.nix
          # ./server/webserver-nginx.nix
          {networking.hostName = "nixos-infra";}
        ];
      };
      nixos-mp-infra = nixpkgs-release.lib.nixosSystem {
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
          ./server/virtual.nix
          # ./server/firefox-sync-server.nix
          # ./server/gitea.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          # ./server/opnborg.nix
          # ./server/opnborg-complex.nix
          # ./server/opnborg-docker-complex.nix
          # ./server/webserver-nginx.nix
          {networking.hostName = "nixos-mp-infra";}
        ];
      };
      nixos-mp-infra-beta = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome2505.nix
          ./person/mpaepcke_luks.nix # XXX
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/chronyPublic.nix
          ./server/unifi.nix
          # ./server/virtual.nix
          # ./server/firefox-sync-server.nix
          # ./server/gitea.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
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
