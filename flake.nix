{
  description = "nixos generic flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-Release.url = "github:NixOS/nixpkgs/nixos-24.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-Release = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-Release";
    };
  };
  outputs = {
    self,
    disko,
    nixpkgs,
    nixpkgs-Release,
    home-manager,
    home-manager-Release,
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
          ./modules/chronyPublic.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          ./server/adguard.nix
          ./server/virtual.nix
          {networking.hostName = "nixos";}
        ];
      };
      nixos-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hardware/macbook.nix
          ./modules/chronyPublic.nix
          ./modules/useBuilder.nix
          ./desktop/gnome.nix
          ./person/desktop/mp.nix
          ./server/adguard.nix
          ./server/openweb-ui.nix
          ./server/unifi.nix
          ./server/virtual.nix
          {networking.hostName = "nixos-mp";}
        ];
      };
      nixos-hyprland = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./modules/chronyPublic.nix
          ./desktop/hyprland.nix
          ./user/desktop/me.nix
          ./server/adguard.nix
          ./server/virtual.nix
          {networking.hostName = "nixos-hyprland";}
        ];
      };
      nixos-hyprland-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hardware/macbook.nix
          ./modules/chronyPublic.nix
          ./desktop/hyprland.nix
          ./person/desktop/mp.nix
          ./server/adguard.nix
          ./server/virtual.nix
          {networking.hostName = "nixos-hyprland-mp";}
        ];
      };
      nixos-console = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./modules/chronyPublic.nix
          ./user/me.nix
          {networking.hostName = "nixos-console";}
        ];
      };
      nixos-console-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hardware/macbook.nix
          ./modules/chronyPublic.nix
          ./person/mp.nix
          {networking.hostName = "nixos-console-mp";}
        ];
      };
      nix-build = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./modules/chronyPublic.nix
          ./server/builder.nix
          ./user/me.nix
          {networking.hostName = "nix-build";}
        ];
      };
      ai = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./server/openweb-ui.nix
          {networking.hostName = "ai";}
        ];
      };
      stargazer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./server/adguard.nix
          {
            networking = {
              hostName = "stargazer";
              domain = "admin.lan";
            };
          }
        ];
      };
      iss = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./server/unifi.nix
          {
            networking = {
              hostName = "iss";
              domain = "admin.lan";
            };
          }
        ];
      };
      iss-command = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          {
            networking = {
              hostName = "iss-command";
              domain = "admin.lan";
            };
          }
        ];
      };
      ########################
      # ISO-INSTALLER-IMAGES #
      ########################
      nixos-iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
          {networking.hostName = "nixos-iso";}
        ];
      };
      #######################
      # LIVE-SYSTEM-BUILDER #
      #######################
      nixos-new = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          {networking.hostName = "nixos-new";}
        ];
      };
    };
  };
}
