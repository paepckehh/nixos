{
  description = "nixos generic flake";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    lib,
    self,
    nixpkgs,
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
          ./server/adguard.nix
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
          ./server/adguard.nix
          ./server/unifi.nix
          {networking.hostName = "nixos-mp";}
        ];
      };
      nixos-hyprland = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/hyprland.nix
          ./user/desktop/me.nix
          ./server/adguard.nix
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
          ./server/adguard.nix
          {networking.hostName = "nixos-hyprland-mp";}
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
          {networking.hostName = "nixos-console-mp";}
        ];
      };
      pinix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          ./server/adguard.nix
          ./server/unifi.nix
          {
            networking.hostName = "pinix";
            services.unifi.openFirewall = lib.mkForce true;
            services.adguard = {
              openFirewall = lib.mkForce true;
              settings = {
                http.address = lib.mkForce "0.0.0.0";
                dns.bindhosts = lib.mkForce "0.0.0.0";
              };
            };
          }
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
