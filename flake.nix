{
  description = "nixos flake";
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
      url = "github:paepckehh/nixos-hardware/master";
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
      ####################
      # LEGACY / GENERIC #
      ####################
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
      nixbook141 = nixpkgs.lib.nixosSystem {
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
      ##################
      # Apple iMac18,2 #
      ##################
      nixmac182-console = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-imac-18-2
          home-manager.nixosModules.home-manager
          ./hardware-configuration.nix
          ./hardware/kb-uk.nix
          ./configuration.nix
        ];
      };
      nixmac182-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-imac-18-2
          home-manager.nixosModules.home-manager
          ./hardware-configuration.nix
          ./hardware/kb-uk.nix
          ./configuration.nix
          ./roles/desktop.nix
          ./modules/virtual.nix
        ];
      };
    };
  };
}
