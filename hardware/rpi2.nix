{
  description = "flake for nixpi2 [ raspberry pi v1.1 32bit armv7 ]";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      # url = "github:NixOS/nixos-hardware/master";
      url = "github:paepckehh/nixos-hardware/master";
    };
  };
  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
  }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "ARMv7-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-2
          home-manager.nixosModules.home-manager
          ../hardware-configuration.nix
          ../hardware/kb-uk.nix
          ../configuration.nix
        ];
      };
    };
  };
}
