{
  description = "nixos infra";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
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
    home-manager,
  }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./iso/disko.nix
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
          ./server/ollama.nix
          # ./server/openweb-ui.nix
          # ./server/webserver-nginx.nix
          # ./server/wiki.nix
          {networking.hostName = "nixos-mp-infra";}
        ];
      };
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations.nixos;
        modules = [
          ./iso/iso.nix
        ];
      };
      nix-auto = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./iso/configuration.nix
          {networking.hostName = "nix-auto";}
        ];
      };
    };
  };
}
