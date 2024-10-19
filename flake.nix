{
  description = "nixos generic flake";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/1840a27";
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:paepckehh/nixpkgs/master";
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
          ./server/virtual.nix
          ./server/docker.nix
          # ./server/gitea.nix
          # ./server/webserver-nginx.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          # ./server/uptime.nix
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
          ./server/virtual.nix
          # ./server/adguard.nix
          # ./server/gitea.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          {networking.hostName = "nixbuilder";}
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
