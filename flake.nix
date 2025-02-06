{
  description = "nixos infra";
  inputs = {
    # ONLINE URLs
    # dns.url = "github:nix-community/dns.nix/master";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko/master";
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # GLOBAL
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    disko,
    home-manager,
    nixpkgs,
  }: let
    #################
    # GLOBAL CONFIG #
    #################
    build.iso.target.hostname = "installer";
    # overlay-unstable = final: prev: {unstable = nixpkgs-unstable.legacyPackages.${prev.system};};
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
          ./modules/disko.nix
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
          # ({ config, pkgs, ... }: {nixpkgs.overlays = [overlay-unstable];})
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./role/client-desktop.nix
          ./modules/disko-luks.nix
          ./person/desktop/mpaepcke.nix
          ./server/mongodb.nix
          # ./server/wazuh.nix
          # ./server/virtual.nix
          # ./server/unifi.nix
          # ./server/opnborg-systemd.nix
          # ./server/cgit.nix
          # ./server/firefox-sync-server.nix
          # ./server/gitea.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          {networking.hostName = "srv-mp";}
        ];
      };
      #############
      # ISO IMAGE #
      #############
      installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./role/adminpc.nix
          ./user/desktop/me.nix
          {networking.hostName = "installer";}
        ];
      };
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations.${build.iso.target.hostname};
        modules = [
          ./modules/iso-autoinstaller.nix
        ];
      };
    };
  };
}
