{
  description = "nixos infra";
  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/25.05";
    # sops.url = "github:mic92/sops-nix";
    # proxmox-nixos.url = "github:saumonnet/proxmox-nixos";
    agenix.url = "github:ryantm/agenix";
    disko.url = "github:nix-community/disko/master";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nvf.url = "github:notashelf/nvf";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # nixpkgs-dev.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-dev.url = "github:paepckehh/nixpkgs/encrypted-dns-server-service";
  };
  outputs = {
    self,
    agenix,
    disko,
    home-manager,
    nixpkgs,
    nixpkgs-dev,
    nvf,
  }: {
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
          ./storage/impermanence.nix
          ./user/desktop/me.nix
          ./packages/base.nix
          ./packages/desktop/gnome.nix
          {networking.hostName = "nixos";}
          {environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ed6058";}
        ];
      };
      nixos-luks = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./storage/impermanence-luks.nix
          ./user/desktop/me.nix
          ./packages/base.nix
          ./packages/desktop/gnome.nix
          {networking.hostName = "nixos";}
          {environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ed6058";}
        ];
      };
      #########
      # KIOSK #
      #########
      kiosk = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          ./storage/impermanence-stateless.nix
          ./packages/desktop/kiosk.nix # see services.cage.program, url => https://start.lan
          {networking.hostName = "kiosk";}
          {environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ed6058";}
        ];
      };
      ############
      # INTERNET #
      ############
      internet = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          ./storage/impermanence-stateless-luks.nix
          ./packages/desktop/browser.nix
          {networking.hostName = "internet";}
          {environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ed6058";}
        ];
      };
      ##########
      # CLIENT #
      ##########
      client = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          nvf.nixosModules.default
          ./configuration.nix
          ./storage/impermanence-luks.nix
          ./client/forward-journald.nix
          ./client/forward-syslog-ng.nix
          ./person/desktop/mpaepcke.nix
          ./packages/base.nix
          ./packages/devops.nix
          ./packages/neovim-nvf.nix
          ./packages/netops.nix
          ./packages/desktop/gnome.nix
          {networking.hostName = "client";}
          {environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ed6058";}
        ];
      };
      ##########
      # SERVER #
      ##########
      srv = nixpkgs-dev.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # proxmox-nixos.nixosModules.proxmox-ve
          # {nixpkgs.overlays = [proxmox-nixos.overlays."x86_64-linux"];}
          agenix.nixosModules.default
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          nvf.nixosModules.default
          ./configuration.nix
          ./client/wireguard.nix
          ./storage/impermanence-luks.nix
          ./openwrt/openwrt.nix
          ./person/desktop/mpaepcke.nix
          ./packages/agenix.nix
          ./packages/base.nix
          ./packages/devops.nix
          ./packages/devops-iot.nix
          ./packages/neovim-nvf.nix
          ./packages/netops.nix
          ./packages/firejail.nix
          ./packages/desktop/gnome.nix
          ./server/bookmarks/readeck.nix
          ./server/devops/atuin.nix
          ./server/devops/olivetin.nix
          ./server/dns/encrypted-dns-server.nix
          {networking.hostName = "srv";}
          {environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ed6058";}
        ];
      };
      ##################
      # ISO LIVE IMAGE #
      ##################
      isonix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations."isonix";
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
