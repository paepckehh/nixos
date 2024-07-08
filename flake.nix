{
  description = "nixos flake mpaepcke";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-boot.url = "github:Melkor333/nixos-boot/master";
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
    nixos-boot,
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
          ./roles/desktop/gnome.nix
          ./person/desktop/mpp.nix
          ./modules/hardening.nix
          {networking.hostName = "generic";}
        ];
      };
      generic-console = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./person/mpp.nix
          ./modules/hardening.nix
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
          nixos-boot.nixosModules.default
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./roles/desktop/gnome.nix
          ./person/desktop/mpp.nix
          ./modules/virtual.nix
          ./modules/hardening.nix
          {networking.hostName = "nixbook141";}
        ];
      };
      nixbook141-hyprland = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./roles/desktop/hyperland.nix
          ./person/desktop/mpp.nix
          ./modules/hardening.nix
          {networking.hostName = "nixbook141-hyprland";}
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
          ./person/mpp.nix
          ./modules/hardening.nix
          {networking.hostName = "nixbook141-console";}
        ];
      };
      nixbook141-office = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./roles/desktop/gnome.nix
          ./roles/office.nix
          ./person/desktop/mpp.nix
          ./modules/hardening.nix
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
          ./hardware/kb-uk.nix
          ./roles/desktop/gnome.nix
          ./roles/office.nix
          ./person/desktop/mpp.nix
          ./modules/virtual.nix
          ./modules/hardening.nix
          {networking.hostName = "nixmac182";}
        ];
      };
    };
  };
}
