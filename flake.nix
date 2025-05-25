{
  description = "nixos infra";
  inputs = {
    # dns.url = "github:nix-community/dns.nix/master";
    # sops.url = "github:mic92/sops-nix";
    proxmox-nixos.url = "github:saumonnet/proxmox-nixos";
    agenix.url = "github:ryantm/agenix";
    disko.url = "github:nix-community/disko/master";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nvf.url = "github:notashelf/nvf";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-dev.url = "github:paepckehh/nixpkgs/fix-atuin";
    # nixpkgs-dev.url = "github:nixos/nixpkgs/nixos-unstable-small";
  };
  outputs = {
    self,
    agenix,
    disko,
    proxmox-nixos,
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
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          ./packages/base.nix
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
          ./desktop/gnome.nix
          ./user/desktop/me.nix
          ./packages/base.nix
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
          ./desktop/kiosk.nix # see services.cage.program, url => https://start.lan
          {networking.hostName = "kiosk";}
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
          ./desktop/gnome.nix
          ./packages/base.nix
          ./packages/devops.nix
          ./packages/neovim-nvf.nix
          ./packages/netops.nix
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
          agenix.nixosModules.default
          disko.nixosModules.disko
          proxmox-nixos.nixosModules.proxmox-ve
          home-manager.nixosModules.home-manager
          nvf.nixosModules.default
          ./configuration.nix
          ./storage/impermanence-luks.nix
          ./person/desktop/mpaepcke.nix
          ./desktop/gnome.nix
          ./packages/agenix.nix
          ./packages/base.nix
          ./packages/devops.nix
          ./packages/devops-iot.nix
          ./packages/neovim-nvf.nix
          ./packages/netops.nix
          ./packages/librewolf.nix
          ./openwrt/openwrt.nix
          ./server/devops/olivetin.nix
          # ./server/devops/atuin.nix
          # ./client/wireguard.nix
          # ./server/bookmarks/readeck.nix
          # ./server/virtual/proxmox.nix
          {networking.hostName = "srv";}
          {environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ed6058";}
          {nixpkgs.overlays = [proxmox-nixos.overlays."x86_64-linux"];}
        ];
      };
      #############
      # ISO IMAGE #
      #############
      iso-live = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations."nixos";
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
