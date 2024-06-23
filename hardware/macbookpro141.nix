{
  description = "flake for nixbookpro141 [ apple macbookpro14,1 ]";
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
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.apple-macbook-pro-14-1
          home-manager.nixosModules.home-manager
          ../hardware-configuration.nix
          ../configuration.nix
          ../roles/desktop.nix
          ../modules/virt.nix
          ../modules/smartcard.nix
        ];
        # adjust keyboard layout
        config.console.keyMap = "gb";
        config.services.xserver.xkb.layout = "gb,de";
      };
    };
  };
}
