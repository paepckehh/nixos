{
  description = "flake for nixbookpro141 [ apple macbookpro14,1 ]";
  inputs = {
    nixpkgs = {
      # url = "github:NixOS/paepckehh/nixos-unstable";
      # url = "github:NixOS/nixpkgs/nixos-24.05";
      # url = "github:NixOS/nixpkgs/master";
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    home-manager = {
      # url = "github:paepckehh/home-manager";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:paepckehh/nixos-hardware/mbp141";
      # url = "github:NixOS/nixos-hardware/master";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
  }: {
    nixosConfigurations = {
      ###########################
      # UNIVERSAL NIXOS DESKTOP #
      ###########################
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./hardware-configuration.nix
          ./hardware/kb-uk.nix
          ./configuration.nix
          ./roles/desktop.nix
          ./modules/virtual.nix
          ./modules/smartcard.nix
        ];
      };
      ######################################
      # Apple MacBookPro14,1 / UK Keyboard #
      ######################################
      nixbook141-console = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./hardware-configuration.nix
          ./hardware/kb-uk.nix
          ./configuration.nix
        ];
      };
      nixbook141-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./hardware-configuration.nix
          ./hardware/kb-uk.nix
          ./configuration.nix
          ./roles/desktop.nix
          ./modules/virtual.nix
        ];
      };
      nixbook141-developer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./hardware-configuration.nix
          ./hardware/kb-uk.nix
          ./configuration.nix
          ./roles/developer.nix
          ./modules/virtual.nix
        ];
      };
      nixbook141-office = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./hardware-configuration.nix
          ./hardware/kb-uk.nix
          ./configuration.nix
          ./roles/office.nix
        ];
      };
    };
  };
}
