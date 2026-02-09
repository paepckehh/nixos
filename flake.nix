{
  description = "nixos infra";
  inputs = {
    # agenix.url = "github:ryantm/agenix";
    # disko.url = "github:nix-community/disko/master";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # home-manager.url = "github:nix-community/home-manager/master";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # proxmox-nixos.url = "git+file:///home/projects/nixos/proxmox-nixos.git";
    # local git mirror
    # nixpkgs.url = "git+file:///home/projects/nixos/nixpkgs.git?ref=master";
    nixpkgs.url = "git+file:///home/projects/nixos/nixpkgs.git?ref=nixos-unstable";
    agenix.url = "git+file:///home/projects/nixos/agenix.git?ref=main";
    disko.url = "git+file:///home/projects/nixos/disko.git?ref=master";
    home-manager.url = "git+file:///home/projects/nixos/home-manager.git?ref=master";
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
          ./hardware/default.nix
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
          ./hardware/default.nix
          ./storage/stateless-luks-partlabel.nix
          ./packages/desktop/browser.nix
          {networking.hostName = "internet";}
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
          ./storage/stateless-luks-fixed-6F6B-6565.nix
          ./configuration.nix
          ./hardware/default.nix
          ./client/addrootCA.nix
          ./client/addCache.nix
          ./client/addYubilock.nix
          ./openwrt/alias.nix
          ./person/desktop/mpaepcke.nix
          ./packages/base.nix
          ./packages/devops-core.nix
          ./packages/desktop/gnome.nix
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
        ];
      };
      srv2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          ./storage/stateless-luks-sequence.nix
          ./configuration.nix
          ./hardware/default.nix
          ./client/addrootCA.nix
          ./client/addCache.nix
          ./person/desktop/mpaepcke.nix
          ./packages/base.nix
          ./packages/devops-core.nix
          ./packages/desktop/gnome.nix
          ./hosts/srv2.nix
        ];
      };
      srv-full = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          # proxmox-nixos.nixosModules.proxmox-ve
          # ./storage/stateless-luks-sequence.nix
          # ./storage/stateless-luks-fixed-AAF0-2F44.nix
          # ./storage/stateless-luks-fixed-2489-EAAA.nix
          # ./storage/stateless-luks-fixed-22A2-C548.nix
          ./storage/stateless-luks-partlabel.nix
          ./configuration.nix
          ./hardware/default.nix
          ./client/addrootCA.nix
          ./client/addCache.nix
          ./openwrt/alias.nix
          ./openwrt/tftp.nix
          ./person/desktop/mpaepcke.nix
          ./packages/desktop/gnome.nix
          ./packages/desktop/add-matrix.nix
          ./packages/desktop/add-onlyoffice.nix
          ./packages/desktop/add-av.nix
          ./packages/base.nix
          ./packages/devops-all.nix
          ./server/base.nix
          ./server/ai/ollama.nix
          ./server/asset/snipeit.nix
          ./server/bookmarks/readeck.nix
          ./server/cache/ncps.nix
          ./server/cloud/nextcloud-container-authelia.nix
          ./server/dns/bind.nix
          ./server/dns/adguard.nix
          ./server/iam/authelia.nix
          ./server/iam/lldap.nix
          ./server/log/syslog-ng.nix
          ./server/mail/maddy-admin.nix
          ./server/message/tuwunel.nix
          ./server/monitoring/grafana.nix
          ./server/monitoring/prometheus.nix
          ./server/ocr/paperless-ngx-authelia.nix
          ./server/search/searx.nix
          ./server/secret/vaultwarden.nix
          ./server/soc/chef.nix
          ./server/it/rackula.nix
          ./server/pki/small-step.nix
          ./server/pki/certwarden.nix
          ./server/pki/mkcertweb.nix
          ./server/pki/vaultls.nix
          ./server/portal/homer-home.nix
          ./server/webapp/res.nix
          ./server/webapp/test.nix
          ./server/cloud/nextcloud-container-authelia.nix
          ./server/rss/miniflux-container-authelia.nix
          ./server/media/immich-container-authelia.nix
          ./server/ocr/paperless-ngx-authelia.nix
          ./server/portal/glance.nix
          ./server/it/networking-toolbox.nix
          ./server/it/web-check.nix
          ./server/time/kimai.nix
          ./server/search/websurfx-systemd.nix
          ./server/sip/coturn.nix
          ./server/message/tuwunel.nix
          ./server/ai/open-webui-container-authelia.nix
          ./hosts/srv.nix
          # ./server/time/kimai-container.nix
          # ./server/office/bentopdf.nix
          # ./server/office/onlyoffice.nix
          # ./packages/desktop/add-onlyoffice.nix
          # ./server/tasks/donetick-docker.nix
          # ./packages/devops-docker.nix
          # ./server/time/timetrack.nix
          # ./server/time/timetrack-docker.nix
          # ./server/ocr/paperless-ngx-authelia.nix
          # ./server/search/websurfx-systemd.nix
          # ./server/sip/coturn.nix
          # ./server/message/tuwunel.nix
          # ./server/wiki/wiki-go-docker.nix
          # ./server/wiki/docmost-docker.nix
          # ./server/ocr/paperless-ngx-authelia.nix
          # ./server/it/networking-toolbox.nix
          # ./server/soc/web-check.nix
          # ./server/ai/open-webui-container-authelia.nix
          # ./server/media/immich-container-authelia.nix
          # ./server/cloud/nextcloud-container-authelia.nix
          # ./server/rss/miniflux-container-authelia.nix
          # ./packages/desktop/add-av.nix
          # ./server/office/onlyoffice.nix
          # ./server/wiki/wiki-go-docker.nix
          # ./server/wiki/docmost-docker.nix
          # ./server/all/timetrack.nix
          # ./server/lora/meshtastic-web.nix
          # ./server/monitoring/kuma.nix
          # ./server/office/onlyoffice.nix
          # ./server/office/onlyoffice-docker.nix
          # ./server/message/element-web.nix
          # ./server/all/ente.nix
          # ./server/media/immich.nix
          # ./server/mail/autoconfig-admin.nix
          # ./server/office/grist.nix
          # ./client/nixbit.nix
          # ./virtual/distrobox.nix
          # ./iot/moode/alias.nix
          # ./server/virtual/proxmox.nix
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
