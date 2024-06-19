{
  description = "flake for nixbookpro141 [ apple macbookpro14,1 ]";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };
  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
  }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          ../hardware-configuration.nix
          ../configuration.nix
          ../add/virt.nix
          ../hardware/macfix.nix
        ];
      };
    };
  };
}
