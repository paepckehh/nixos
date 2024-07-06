{
  description = "nixos flake mpaepcke";
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
      ###########
      # GENERIC #
      ###########
      generic = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./roles/desktop.nix
          ./modules/virtual.nix
          ./hardware/kb-uk.nix
          {networking.hostName = "generic";}
        ];
      };
      generic-console = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hardware/kb-uk.nix
          {networking.hostName = "generic-console";}
        ];
      };
      ###########################################
      # APPLE MacBookPro14,1 / UK int. Keyboard #
      ###########################################
      nixbook141 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./roles/desktop.nix
          ./modules/virtual.nix
          ./hardware/kb-uk.nix
          {networking.hostName = "nixbook141";}
        ];
      };
      nixbook141-iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
          {networking.hostName = "nixbook141-iso";}
        ];
      };
      nixbook141-console = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hardware/kb-uk.nix
          {networking.hostName = "nixbook141-console";}
        ];
      };
      nixbook141-office = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./roles/office.nix
          ./hardware/kb-uk.nix
          {networking.hostName = "nixbook141-office";}
        ];
      };
      ##################
      # APPLE iMac18,2 #
      ##################
      nixmac182 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-imac-18-2
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./roles/office.nix
          ./modules/virtual.nix
          ./hardware/kb-uk.nix
          {networking.hostName = "nixmac182";}
        ];
      };
    };
  };
}
