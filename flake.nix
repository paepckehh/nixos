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
          ./storage/stateless.nix
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
          ./storage/stateless-luks.nix
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
          ./storage/stateless.nix
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
          ./storage/stateless-luks.nix
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
          agenix.nixosModules.default
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          nvf.nixosModules.default
          ./configuration.nix
          ./storage/stateless-luks.nix
          ./client/addrootCA.nix
          ./client/forward-syslog-ng.nix
          ./client/wifi-base.nix
          ./client/wireguard-wg110.nix
          ./person/desktop/mpaepcke.nix
          ./packages/agenix.nix
          ./packages/base.nix
          ./packages/devops-all.nix
          ./packages/firejail.nix
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
          ./client/db.nix
          ./client/addrootCA.nix
          ./storage/stateless-luks.nix
          ./openwrt/alias.nix
          ./iot/moode/alias.nix
          ./person/desktop/mpaepcke.nix
          ./packages/desktop/gnome.nix
          ./packages/agenix.nix
          ./packages/base.nix
          ./packages/devops-core.nix
          ./server/monitoring/collect-syslog-ng.nix
          ./server/cloud/nextcloud.nix
          ./server/dns/bind.nix
          # ./server/iam/authelia.nix
          # ./server/iam/lldap.nix
          ./server/search/searx.nix
          ./server/portal/homer.nix
          ./server/pki/small-step.nix
          ./server/pki/mkcertweb.nix
          ./server/pki/vaultls.nix
          # ./server/pki/certwarden.nix
          # ./server/share/nextcloud.nix
          # ./server/ticket/zammad.nix
          # ./server/devops/openvs-code.nix
          # ./virtual/distrobox.nix
          # ./client/wireguard-wg100.nix
          # ./packages/desktop/dss-portal.nix
          # ./packages/desktop/firejail.nix
          # ./packages/desktop/add-thunderbird.nix
          # ./packages/desktop/add-onlyoffice.nix
          # ./packages/desktop/add-matrix.nix
          # ./packages/desktop/add-onlyoffice.nix
          # ./server/asset/snipeit.nix
          # ./server/ocr/paperless-ai.nix
          # ./server/portal/homer.nix
          # ./server/devops/vscode.nix
          # ./server/doc/stirling.nix
          # ./server/crm/wordpress.nix
          # ./server/rss/miniflux.nix
          # ./server/share/immich.nix
          # ./server/share/wastebin.nix
          # ./server/share/paperless.nix
          # ./server/share/mediawiki.nix
          # ./server/lang/libretranslate.nix
          # ./server/cloud/nextcloud.nix
          # ./server/office/onlyoffice-docker.nix
          # ./server/ai/ollama.nix
          # ./server/ai/openweb-ui.nix
          # ./server/message/element-web.nix
          # ./server/message/tuwunel.nix
          # ./server/mail/davis.nix
          # ./server/mail/open-web-calendar.nix
          # ./server/hr/timeoff.nix
          # ./server/dns/adguard.nix
          # ./server/pki/small-step.nix
          # ./server/mail/roundcube.nix
          # ./server/devops/olivetin.nix
          # ./server/soc/chef.nix
          # ./server/soc/proxy.nix
          # ./server/monitoring/kuma.nix
          # ./server/monitoring/prometheus-opnsense.nix
          # ./server/monitoring/grafana.nix
          # ./server/monitoring/prometheus.nix
          # ./server/devops/atuin.nix
          # ./server/bookmarks/webdav.nix
          # ./server/bookmarks/readeck.nix
          # ./server/dns/unbound.nix
          # ./server/soc/netalertx.nix
          # ./server/soc/wazuh.nix
          ./hosts/srv.nix
          {networking.hostName = "srv";}
          {networking.hostId = "3f95770b";} # head -c 8 /etc/maschine-id
          {environment.etc."machine-id".text = "3f95770b57a4651bdf43a8c168cfb740";} # dbus-uuidgen
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
