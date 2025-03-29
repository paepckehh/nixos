{
  description = "nixos infra";
  inputs = {
    # ONLINE URLs
    # nixpkgs.url = "github:paepckehh/nixpkgs/blocky-improve";
    # nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # dns.url = "github:nix-community/dns.nix/master";
    # nixvim.url = "github:nix-community/nixvim/master";
    nvf.url = "github:notashelf/nvf";
    disko.url = "github:nix-community/disko/master";
    home-manager.url = "github:nix-community/home-manager/master";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    nixpkgs-unstable.url = "github:paepckehh/nixpkgs/prometheus-exporter";
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
          ./configuration.nix
          ./alias/nixops.nix
          ./modules/disko-luks.nix
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          ./packages/base.nix
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
          ./configuration.nix
          ./alias/nixops.nix
          ./modules/disko-luks.nix
          ./desktop/gnome.nix
          ./person/desktop/mpaepcke.nix
          ./packages/base.nix
          {networking.hostName = "client-mp";}
        ];
      };
      ##########
      # SERVER #
      ##########
      srv-mp = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({config, ...}: {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [overlay-unstable];
          })
          nvf.nixosModules.default
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./alias/nixops.nix
          ./modules/disko-luks.nix
          ./desktop/gnome.nix
          ./person/desktop/mpaepcke.nix
          ./packages/neovim-nvf.nix
          ./packages/unstable-base.nix
          ./packages/unstable-netops.nix
          ./packages/unstable-devops.nix
          ./server/ntp/chronyPublic.nix
          ./server/dns/blocky.nix
          ./server/dns/blocky-add-prometheus.nix
          ./server/dns/blocky-add-query-stats.nix
          ./server/monitoring/prometheus-exporter.nix
          # ./server/ai/ollama.nix
          # ./server/ai/openweb-ui.nix
          # ./server/db/mysql.nix
          # ./server/db/mongodb.nix
          # ./server/unifi/unifi.nix
          # ./server/monitoring/wazuh.nix
          # ./server/virtual/virtual.nix
          # ./server/opnborg/opnborg-systemd.nix
          # ./server/web/cgit.nix
          # ./server/infra/firefox-sync-server.nix
          # ./server/infra/gitea.nix
          # ./server/infra/home-assistant.nix
          {networking.hostName = "srv-mp";}
        ];
      };
      #############
      # ISO IMAGE #
      #############
      iso-installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations."nixos";
        modules = [
          ./modules/iso-autoinstaller.nix
        ];
      };
    };
  };
}
