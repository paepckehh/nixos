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
      url = "github:NixOS/nixos-hardware/master";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
  }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-2
          ../hardware-configuration.nix
          ../configuration.nix
          ../modules/hw-hardening.nix
        ];
      };
    };
  };
}
