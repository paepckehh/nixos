{
  description = "nixos infra";
  inputs = {
    # ONLINE URLs
    disko.url = "github:nix-community/disko/master";
    dns.url = "github:nix-community/dns.nix/master";
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
    dns,
    home-manager,
    nixpkgs,
    nixpkgs-unstable,
  }: let
    # GLOBAL
    nix-iso-target-hostname = "nixos";
    overlay-unstable = final: prev: {unstable = nixpkgs-unstable.legacyPackages.${prev.system};};
  in {
    nixosConfigurations = {
      ###########
      # GENERIC #
      ###########
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
      ##########
      # CLIENT #
      ##########
      client-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./role/client-desktop.nix
          ./person/desktop/mpaepcke.nix
          {networking.hostName = "client-mp";}
        ];
      };
      ##########
      # SERVER #
      ##########
      srv-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({
            config,
            pkgs,
            ...
          }: {nixpkgs.overlays = [overlay-unstable];})
          disko.nixosModules.disko
          dns.nixosModules.dns.nix
          home-manager.nixosModules.home-manager
          ./hosts/srv-mp.nix
          ./role/client-desktop.nix
          ./person/mpaepcke_luks.nix
          ./person/desktop/mpaepcke.nix
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
      #############
      # ISO IMAGE #
      #############
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations.${nix-iso-target-hostname};
        modules = [
          ./modules/iso-autoinstaller.nix
        ];
      };
    };
  };
}
