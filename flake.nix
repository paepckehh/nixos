{
  description = "nixos infra";
  inputs = {
    # ONLINE URLs
    # nixpkgs.url = "github:paepckehh/nixpkgs/blocky-improve";
    # nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    dns.url = "github:nix-community/dns.nix/master";
    disko.url = "github:nix-community/disko/master";
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    # settings
    # dns.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    disko,
    dns,
    home-manager,
    nixpkgs,
    nixpkgs-unstable,
    nixvim,
  }: let
    #################
    # GLOBAL CONFIG #
    #################
    build.installer.iso.target.hostname = "nix-installer";
    overlay-unstable = final: prev: {
      unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config = {
          allowUnfreePredicate = pkg: true;
          allowUnfree = true;
        };
      };
    };
  in {
    nixosConfigurations = {
      ###########
      # GENERIC #
      ###########
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./modules/disko.nix
          ./role/client-desktop.nix
          ./user/desktop/me.nix
          {networking.hostName = "nixos";}
        ];
      };
      ##########
      # CLIENT #
      ##########
      client-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./role/client-desktop.nix
          ./modules/disko.nix
          ./person/desktop/mpaepcke.nix
          {networking.hostName = "client-mp";}
        ];
      };
      ##########
      # SERVER #
      ##########
      srv-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({
            config,
            pkgs,
            ...
          }: {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [overlay-unstable];
          })
          nixvim.nixosModules.nixvim
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./role/client-desktop.nix
          ./modules/disko-luks.nix
          ./person/desktop/mpaepcke.nix
          ./user/dev-env-go.nix
          # ./server/ollama.nix
          # ./server/openweb-ui.nix
          # ./server/home-assistant.nix
          # ./server/mysql.nix
          # ./server/mongodb.nix
          # ./server/unifi.nix
          # ./server/wazuh.nix
          # ./server/virtual.nix
          # ./server/opnborg-systemd.nix
          # ./server/cgit.nix
          # ./server/firefox-sync-server.nix
          # ./server/gitea.nix
          {networking.hostName = "srv-mp";}
        ];
      };
      #############
      # ISO IMAGE #
      #############
      nix-installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./modules/disko.nix
          ./role/client-desktop.nix
          ./user/desktop/me.nix
          {networking.hostName = "nix-installer";}
        ];
      };
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations.${build.installer.iso.target.hostname};
        modules = [
          ./modules/iso-autoinstaller.nix
        ];
      };
    };
  };
}
