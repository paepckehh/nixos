{
  description = "nixos infra";
  inputs = {
    # ONLINE URLs
    # dns.url = "github:nix-community/dns.nix/master";
    # sops.url = "github:mic92/sops-nix";
    agenix.url = "github:ryantm/agenix";
    disko.url = "github:nix-community/disko/master";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nvf.url = "github:notashelf/nvf";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-dev.url = "github:nixos/nixpkgs/nixos-unstable";
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
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./desktop/kiosk.nix
          ./storage/disko-luks-legacy.nix
          # ./storage/impermanence-stateless.nix
          {networking.hostName = "kiosk";}
          {environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ed6058";}
          {services.cage.program = nixpkgs.lib.mkForce "${nixpkgs.librewolf}/bin/librewolf -kiosk -private-window https://start.lan";}
        ];
      };
      ##########
      # CLIENT #
      ##########
      mp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          nvf.nixosModules.default
          ./configuration.nix
          ./storage/impermanence-luks.nix
          ./client/forward-journald.nix
          ./client/forward-syslog-ng.nix
          ./desktop/gnome.nix
          ./person/desktop/mpaepcke.nix
          ./packages/base.nix
          ./packages/devops.nix
          ./packages/neovim-nvf.nix
          ./packages/netops.nix
          {networking.hostName = "mp";}
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
          home-manager.nixosModules.home-manager
          nvf.nixosModules.default
          ./configuration.nix
          ./storage/impermanence.nix
          ./desktop/gnome.nix
          ./person/desktop/mpaepcke.nix
          ./packages/agenix.nix
          ./packages/base.nix
          ./packages/devops.nix
          ./packages/neovim-nvf.nix
          ./packages/netops.nix
          ./openwrt/openwrt.nix
          {networking.hostName = "srv";}
          {environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ed6058";}
        ];
      };
      srv-mp = nixpkgs-dev.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          nvf.nixosModules.default
          ./configuration.nix
          ./storage/disko-luks-legacy.nix
          ./desktop/gnome.nix
          ./person/desktop/mpaepcke.nix
          ./packages/agenix.nix
          ./packages/base.nix
          ./packages/devops.nix
          ./packages/devops-iot.nix
          ./packages/neovim-nvf.nix
          ./packages/netops.nix
          ./openwrt/openwrt.nix
          ./server/share/wastebin.nix
          # ./server/monitoring/collect-journald.nix
          # ./server/monitoring/collect-syslog-ng.nix
          # ./server/dns/unbound.nix
          # ./server/dns/blocky.nix
          # ./server/dns/blocky-add-filter.nix
          # ./server/dns/blocky-add-log-file.nix
          # ./server/dns/blocky-add-resolver-privacy-small.nix
          # ./server/virtual/teable.nix
          # ./server/dns/blocky-add-log-postgres.nix
          # ./server/dns/blocky-add-resolver-dnscrypt.nix
          # ./server/dns/blocky-add-resolver-unbound.nix
          # ./server/dns/blocky-add-resolver-privact-small.nix
          # ./server/dns/blocky-add-monitoring-prometheus.nix
          # ./server/iam/zitadel.nix
          # ./server/vpn/netbird.nix
          # ./iot/ecoflow-mqtt.nix
          # ./iot/tibber.nix
          # ./server/ntp/chrony-add-prometheus-local.nix
          # ./server/monitoring/prometheus-exporter.nix
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
          {environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ed6058";}
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
        specialArgs.targetSystem = self.nixosConfigurations."nixos";
        modules = [
          ./storage/iso-autoinstaller.nix
        ];
      };
      iso-legacy-installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.targetSystem = self.nixosConfigurations."nixos-legacy";
        modules = [
          ./storage/iso-legacy-autoinstaller.nix
        ];
      };
    };
  };
}
