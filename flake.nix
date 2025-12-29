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
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          # ./storage/stateless-luks-sequence.nix
          # ./storage/stateless-luks-partlabel.nix
          ./storage/stateless-luks-fixed-22A2-C548.nix
          ./configuration.nix
          ./client/addrootCA.nix
          ./client/addCache.nix
          ./openwrt/alias.nix
          ./person/desktop/mpaepcke.nix
          ./packages/base.nix
          ./packages/devops-core.nix
          ./packages/desktop/gnome.nix
          ./packages/desktop/add-onlyoffice.nix
          ./packages/desktop/add-av.nix
          ./packages/desktop/add-chrome.nix
          ./server/base.nix
          ./server/ai/ollama.nix
          ./server/cache/ncps.nix
          ./server/dns/bind.nix
          ./server/iam/authelia.nix
          ./server/iam/lldap.nix
          ./server/log/syslog-ng.nix
          ./server/lora/meshtastic-web.nix
          ./server/search/searx.nix
          ./server/pki/small-step.nix
          ./server/portal/homer-home.nix
          ./server/webapp/res.nix
          ./server/webapp/test.nix
          ./hosts/srv.nix
          # ./server/ai/open-webui-authelia.nix
          # ./server/cloud/nextcloud-authelia.nix
          # ./server/ocr/paperless-ngx-authelia.nix
          # ./server/media/immich-authelia.nix
          # ./server/office/onlyoffice-docker.nix
          # ./server/rss/miniflux.nix
          # ./server/office/onlyoffice.nix
          {networking.hostName = "srv";}
          {networking.hostId = "3f95770b";} # head -c 8 /etc/maschine-id
          {environment.etc."machine-id".text = "3f95770b57a4651bdf43a8c168cfb740";} # dbus-uuidgen
        ];
      };
      ##########
      # SERVER #
      ##########
      srv-full = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          # ./storage/stateless-luks-sequence.nix
          # ./storage/stateless-luks-partlabel.nix
          # ./storage/stateless-luks-fixed-AAF0-2F44.nix
          # ./storage/stateless-luks-fixed-2489-EAAA.nix
          ./storage/stateless-luks-fixed-22A2-C548.nix
          ./configuration.nix
          ./client/addrootCA.nix
          ./client/addCache.nix
          ./openwrt/alias.nix
          ./openwrt/tftp.nix
          ./person/desktop/mpaepcke.nix
          ./packages/desktop/gnome.nix
          ./packages/desktop/add-matrix.nix
          ./packages/desktop/add-onlyoffice.nix
          ./packages/desktop/add-av.nix
          ./packages/desktop/add-chrome.nix
          ./packages/base.nix
          ./packages/devops-all.nix
          ./server/base.nix
          ./server/ai/ollama.nix
          ./server/ai/open-webui-authelia.nix
          ./server/asset/snipeit.nix
          ./server/bookmarks/readeck.nix
          ./server/cache/ncps.nix
          ./server/cloud/nextcloud-authelia.nix
          ./server/dns/bind.nix
          ./server/dns/adguard.nix
          ./server/iam/authelia.nix
          ./server/iam/lldap.nix
          ./server/log/syslog-ng.nix
          ./server/lora/meshtastic-web.nix
          ./server/mail/maddy-admin.nix
          ./server/media/immich-authelia.nix
          ./server/message/tuwunel.nix
          ./server/monitoring/kuma.nix
          ./server/monitoring/grafana.nix
          ./server/monitoring/prometheus.nix
          ./server/ocr/paperless-ngx-authelia.nix
          ./server/office/onlyoffice.nix
          ./server/search/searx.nix
          ./server/secret/vaultwarden.nix
          ./server/soc/chef.nix
          ./server/pki/small-step.nix
          ./server/pki/certwarden.nix
          ./server/pki/mkcertweb.nix
          ./server/pki/vaultls.nix
          ./server/portal/homer-home.nix
          ./server/webapp/res.nix
          ./server/webapp/test.nix
          ./server/rss/miniflux.nix
          # ./server/message/element-web.nix
          # ./server/media/ente.nix
          # ./server/media/immich.nix
          # ./server/mail/autoconfig-admin.nix
          # ./server/portal/glance.nix
          # ./server/office/grist.nix
          # ./client/nixbit.nix
          # ./virtual/distrobox.nix
          # ./iot/moode/alias.nix
          # ./packages/desktop/dss-portal.nix
          # ./packages/desktop/firejail.nix
          # ./packages/desktop/add-thunderbird.nix
          # ./server/ocr/paperless-ai.nix
          # ./server/portal/homer.nix
          # ./server/portal/homer-it.nix
          # ./server/ticket/zammad.nix
          # ./server/devops/openvs-code.nix
          # ./server/doc/stirling.nix
          # ./server/crm/wordpress.nix
          # ./server/share/wastebin.nix
          # ./server/share/mediawiki.nix
          # ./server/lang/libretranslate.nix
          # ./server/cloud/nextcloud.nix
          # ./server/office/onlyoffice-docker.nix
          # ./server/ai/openweb-ui.nix
          # ./server/mail/davis.nix
          # ./server/mail/open-web-calendar.nix
          # ./server/hr/timeoff.nix
          # ./server/mail/roundcube.nix
          # ./server/devops/olivetin.nix
          # ./server/soc/proxy.nix
          # ./server/monitoring/prometheus-opnsense.nix
          # ./server/devops/atuin.nix
          # ./server/bookmarks/webdav.nix
          # ./server/dns/unbound.nix
          # ./server/soc/netalertx.nix
          # ./server/soc/wazuh.nix
          ./hosts/srv.nix
          {networking.hostName = "srv-full";}
          {networking.hostId = "3f95770b";} # head -c 8 /etc/maschine-id
          {environment.etc."machine-id".text = "3f95770b57a4651bdf43a8c168cfb740";} # dbus-uuidgen
        ];
      };
      ##################
      # ISO LIVE IMAGE #
      ##################
      client = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
          ./storage/base.nix
          ./user/desktop/me.nix
          ./packages/base.nix
          ./packages/desktop/gnome.nix
          {networking.hostName = "client";}
          {environment.etc."machine-id".text = "d4f98853253040fea71e4fe946ee6058";}
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
