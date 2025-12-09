{
  description = "nixos infra";
  inputs = {
    # agenix.url = "github:ryantm/agenix";
    # disko.url = "github:nix-community/disko/master";
    # nvf.url = "github:notashelf/nvf";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # home-manager.url = "github:nix-community/home-manager/master";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nvf.url = "git+file:///home/projects/nixos/nvf.git";
    # local git mirror
    nixpkgs.url = "git+file:///home/projects/nixos/nixpkgs.git?ref=nixos-unstable";
    agenix.url = "git+file:///home/projects/nixos/agenix.git";
    disko.url = "git+file:///home/projects/nixos/disko.git";
    home-manager.url = "git+file:///home/projects/nixos/home-manager.git";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    agenix,
    disko,
    home-manager,
    nixpkgs,
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
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./storage/stateless-luks-partlabel.nix
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
          ./configuration.nix
          ./storage/stateless-luks-partlabel.nix
          ./packages/desktop/browser.nix
          {networking.hostName = "internet";}
          {environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ed6058";}
        ];
      };
      ##########
      # SERVER #
      ##########
      srv = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # proxmox-nixos.nixosModules.proxmox-ve
          # {nixpkgs.overlays = [proxmox-nixos.overlays."x86_64-linux"];}
          # disko.nixosModules.disko
          # nvf.nixosModules.default
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          ./storage/stateless-luks-fixed-AAF0-2F44.nix
          # ./storage/stateless-luks-fixed-2489-EAAA.nix
          # ./storage/stateless-luks-sequence.nix
          # ./storage/stateless-luks-partlabel.nix
          ./configuration.nix
          ./client/addrootCA.nix
          ./client/addCache.nix
          ./openwrt/alias.nix
          ./person/desktop/mpaepcke.nix
          ./packages/desktop/gnome.nix
          ./packages/base.nix
          ./packages/devops-core.nix
          ./packages/devops-lora.nix
          # ./server/ai/open-webui-authelia.nix
          ./server/base.nix
          ./server/bookmarks/readeck.nix
          ./server/cache/ncps.nix
          # ./server/cloud/nextcloud-authelia.nix
          ./server/dns/bind.nix
          ./server/iam/authelia.nix
          ./server/iam/lldap.nix
          ./server/log/syslog-ng.nix
          ./server/lora/meshtastic-web.nix
          ./server/mail/autoconfig-admin.nix
          ./server/mail/maddy-admin.nix
          ./server/search/searx.nix
          ./server/secret/vaultwarden.nix
          ./server/pki/small-step.nix
          ./server/portal/homer-home.nix
          # ./server/ocr/paperless-ngx-authelia.nix
          ./server/webapp/res.nix
          ./server/webapp/test.nix
          # ./server/office/grist.nix
          # ./client/nixbit.nix
          # ./virtual/distrobox.nix
          # ./iot/moode/alias.nix
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
          # ./server/dns/adguard.nix
          # ./server/portal/homer-it.nix
          # ./server/pki/certwarden.nix
          # ./server/pki/mkcertweb.nix
          # ./server/pki/vaultls.nix
          # ./server/ticket/zammad.nix
          # ./server/devops/openvs-code.nix
          # ./server/doc/stirling.nix
          # ./server/crm/wordpress.nix
          # ./server/rss/miniflux.nix
          # ./server/share/immich.nix
          # ./server/share/wastebin.nix
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
