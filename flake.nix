{
  description = "nixos infra";
  inputs = {
    # ONLINE URLs
    nixpkgs.url = "github:paepckehh/nixpkgs/blocky-improve";
    # nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # dns.url = "github:nix-community/dns.nix/master";
    # nixvim.url = "github:nix-community/nixvim/master";
    nvf.url = "github:notashelf/nvf";
    disko.url = "github:nix-community/disko/master";
    home-manager.url = "github:nix-community/home-manager/master";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # settings
    # dns.inputs.nixpkgs.follows = "nixpkgs";
    # nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nvf.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    disko,
    home-manager,
    nixpkgs,
    nixpkgs-unstable,
    nvf,
  }: let
    #################
    # GLOBAL CONFIG #
    #################
    # deadnix: skip
    overlay-unstable = pre: final: {
      unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config = {
          # deadnix: skip
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
          ./packages/base.nix
          {networking.hostName = "client-mp";}
        ];
      };
      ##########
      # SERVER #
      ##########
      srv-mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({config, ...}: {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [overlay-unstable];
          })
          nvf.nixosModules.default
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./alias/nixops.nix
          ./configuration.nix
          ./modules/disko-luks.nix
          ./desktop/gnome.nix
          ./server/unbound.nix
          ./server/blocky.nix
          ./server/chronyPublic.nix
          ./person/desktop/mpaepcke.nix
          ./packages/neovim-nvf.nix
          ./packages/unstable-base.nix
          ./packages/unstable-netops.nix
          ./packages/unstable-devops.nix
          ./server/ollama.nix
          # ./server/home-assistant.nix
          # ./server/openweb-ui.nix
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
          ./packages/base.nix
          {networking.hostName = "nix-installer";}
        ];
      };
      iso-installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations."nix-installer";
        modules = [
          ./modules/iso-autoinstaller.nix
        ];
      };
    };
  };
}
