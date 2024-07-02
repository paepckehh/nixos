{
  description = "nixos flake";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:paepckehh/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
  }: {
    nixosConfigurations = {
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
          {networking.hostName = "nixbook141";}
        ];
      };
      nixbook141-iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./hardware-configuration.nix
          ./hardware/kb-uk.nix
          ./configuration.nix
          ./roles/desktop.nix
          ./modules/virtual.nix
          {networking.hostName = "nixbook141";}
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
          {networking.hostName = "nixbook141-console";}
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
          {networking.hostName = "nixbook141-office";}
        ];
      };
      ##################
      # Apple iMac18,2 #
      ##################
      nixmac182 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-imac-18-2
          home-manager.nixosModules.home-manager
          ./hardware-configuration.nix
          ./hardware/kb-uk.nix
          ./configuration.nix
          ./roles/office.nix
          ./modules/virtual.nix
          {networking.hostName = "nixmac182";}
        ];
      };
      nixmac182-console = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-imac-18-2
          home-manager.nixosModules.home-manager
          ./hardware-configuration.nix
          ./hardware/kb-uk.nix
          ./configuration.nix
          {networking.hostName = "nixmac182-console";}
        ];
      };
    };
  };
}
