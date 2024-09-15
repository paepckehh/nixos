{
  description = "nixos generic flake";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/1840a27";
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
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
          ./hardware/nvidia-off.nix
          ./modules/chronyPublic.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          ./server/adguard.nix
          {networking.hostName = "nixos";}
        ];
      };
      nixos-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hardware/macbook-intel.nix
          ./modules/chronyPublic.nix
          ./desktop/gnome.nix
          ./person/desktop/mpaepcke.nix
          ./server/adguard.nix
          ./server/ollama.nix
          ./server/openweb-ui.nix
          ./server/virtual.nix
          # ./server/gitea.nix
          # ./server/unifi.nix
          # ./server/wiki.nix
          {networking.hostName = "nixos-mp";}
        ];
      };
      nixos-console = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hardware/nvidia-off.nix
          ./modules/chronyPublic.nix
          ./server/adguard.nix
          ./user/me.nix
          {networking.hostName = "nixos-console";}
        ];
      };
      nixos-console-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hardware/nvidia-off.nix
          ./hardware/macbook-intel.nix
          ./modules/chronyPublic.nix
          ./server/adguard.nix
          ./person/mpaepcke.nix
          {networking.hostName = "nixos-console-mp";}
        ];
      };
      nixbuilder = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./hardware/nvidia-off.nix
          ./modules/chronyPublic.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          ./server/builder.nix
          # ./server/adguard.nix
          # ./server/gitea.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          {networking.hostName = "nixbuilder";}
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
              wireless.enable = false;
            };
            hardware.bluetooth.enable = false;
          }
        ];
      };
      iss-command-tk = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          {
            networking = {
              hostName = "iss-command-tk";
              domain = "admin.lan";
              wireless.enable = false;
            };
            hardware.bluetooth.enable = false;
          }
        ];
      };
      iss-command-jk = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          {
            networking = {
              hostName = "iss-command-jk";
              domain = "admin.lan";
              wireless.enable = false;
            };
            hardware.bluetooth.enable = false;
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
