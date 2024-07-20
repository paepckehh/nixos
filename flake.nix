{
  description = "nixos generic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgsMaster.url = "github:NixOS/nixpkgs/master";
    nixpkgsRelease.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixpkgsMaster,
    nixpkgsRelease,
    home-manager,
  }: {
    nixosConfigurations = {
      #################
      # GENERIC NIXOS #
      #################
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          {networking.hostName = "nixos";}
        ];
      };
      nixos-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./person/desktop/mp.nix
          {networking.hostName = "nixos";}
        ];
      };
      nixos-hyprland = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/hyprland.nix
          ./user/desktop/me.nix
          {networking.hostName = "nixos-hyprland";}
        ];
      };
      nixos-hyprland-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/hyprland.nix
          ./person/desktop/mp.nix
          {networking.hostName = "nixos-hyprland";}
        ];
      };
      nixos-console = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./person/me.nix
          {networking.hostName = "nixos-console";}
        ];
      };
      nixos-console-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./person/mp.nix
          {networking.hostName = "nixos-console";}
        ];
      };
      nix-name = nixpkgsRelease.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./server/adguard.nix
          ./user/me.nix
          {networking.hostName = "nix-name";}
        ];
      };
      nixos-iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
          {networking.hostName = "nixos-iso";}
        ];
      };
    };
  };
}
