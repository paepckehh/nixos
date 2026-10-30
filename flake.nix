{
  description = "nixos infra global config flake";
  inputs = {
    # ### online
    # nixpkgs.url      = "github:nixos/nixpkgs?ref=nixos-unstable";
    # agenix.url       = "github:ryantm/agenix?ref=main";
    # disko.url        = "github:nix-community/disko?ref=master";
    # home-manager.url = "github:nix-community/home-manager?ref=master";
    # ### local-fs
    # nixpkgs.url = "git+file:///nix/persist/cache/git-mirror/nixos/nixpkgs?ref=nixos-unstable";
    # agenix.url = "git+file:///nix/persist/cache/git-mirror/ryantm/agenix?ref=main";
    # disko.url = "git+file:///nix/persist/cache/git-mirror/nix-community/disko?ref=master";
    # home-manager.url = "git+file:///nix/persist/cache/git-mirror/nix-community/home-manager?ref=master";
    # ### private-cloud
    nixpkgs-dev.url = "git+https://git-mirror.home.corp/nixos/nixpkgs?ref=nixos-unstable-small";
    nixpkgs.url = "git+https://git-mirror.home.corp/nixos/nixpkgs?ref=nixos-unstable";
    agenix.url = "git+https://git-mirror.home.corp/ryantm/agenix?ref=main";
    disko.url = "git+https://git-mirror.home.corp/nix-community/disko?ref=master";
    home-manager.url = "git+https://git-mirror.home.corp/nix-community/home-manager?ref=master";
    # ### shared
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    agenix,
    disko,
    home-manager,
    nixpkgs,
    nixpkgs-dev,
  } @ inputs: let
    infra = (import siteconfig/home.nix).infra;
    mkHost = host:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit self inputs infra;};
        modules = [
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          ./hosts/${host}.nix
        ];
      };
  in {
    nixosConfigurations = {
      srv = mkHost "srv";
      srv2 = mkHost "srv2";
      kiosk = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit self inputs;};
        modules = [
          ./configuration.nix
          ./hardware/all.nix
          ./storage/stateless.nix
          ./packages/desktop/kiosk.nix
          {networking.hostName = "kiosk";}
        ];
      };
      internet = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit self inputs;};
        modules = [
          ./configuration.nix
          ./hardware/all.nix
          ./storage/stateless-luks-partlabel.nix
          ./packages/desktop/browser.nix
          {networking.hostName = "internet";}
        ];
      };
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations."client";
        modules = [
          ./storage/iso-live.nix
        ];
      };
      iso-installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations."nixos-luks";
        modules = [
          disko.nixosModules.disko
          ./storage/basic.nix
          ./storage/iso-autoinstaller.nix
        ];
      };
    };
  };
}
