{
  description = "nixos infra global config flake";
  inputs = {
    # ### online
    # nixpkgs.url      = "github:nixos/nixpkgs?ref=nixos-unstable";
    # agenix.url       = "github:ryantm/agenix?ref=main";
    # disko.url        = "github:nix-community/disko?ref=master";
    # home-manager.url = "github:nix-community/home-manager?ref=master";
    # ### private-cloud
    # nixpkgs.url = "git+https://git-mirror.home.corp/nixos/nixpkgs?ref=nixos-unstable";
    # agenix.url = "git+https://git-mirror.home.corp/ryantm/agenix?ref=main";
    # disko.url = "git+https://git-mirror.home.corp/nix-community/disko?ref=master";
    # home-manager.url = "git+https://git-mirror.home.corp/nix-community/home-manager?ref=master";
    # ### local-fs
    nixpkgs.url = "git+file:///nix/persist/cache/git-mirror/nixos/nixpkgs?ref=nixos-unstable";
    agenix.url = "git+file:///nix/persist/cache/git-mirror/ryantm/agenix?ref=main";
    disko.url = "git+file:///nix/persist/cache/git-mirror/nix-community/disko?ref=master";
    home-manager.url = "git+file:///nix/persist/cache/git-mirror/nix-community/home-manager?ref=master";
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
          ./hardware/all.nix
          ./storage/stateless.nix
          ./packages/desktop/kiosk.nix
          {networking.hostName = "kiosk";}
        ];
      };
      ############
      # INTERNET #
      ############
      internet = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./hardware/all.nix
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
          ./hosts/srv.nix
          ./role/server.nix
          # ./storage/stateless-luks-sequence.nix
          ./storage/stateless-luks-fixed-6F6B-6565.nix
          ./configuration.nix
          ./hardware/all.nix
          ./client/addrootCA.nix
          ./client/addrootCA-ext.nix
          ./client/addCache.nix
          ./openwrt/alias.nix
          ./person/desktop/mpaepcke.nix
          ./packages/devops-core.nix
          ./packages/desktop/gnome.nix
          ./server/ai/ollama01.nix
          ./server/dns/bind.nix
          ./server/iam/authelia.nix
          ./server/iam/lldap.nix
          ./server/infra/ncps.nix
          ./server/infra/git-mirror-scripts.nix
          ./server/infra/git-mirror-container.nix
          ./server/infra/syslog-ng.nix
          ./server/search/searx.nix
          ./server/pki/small-step.nix
          ./server/portal/homer-home-container.nix
          ./server/webapp/res.nix
          ./server/win/winstart.nix
          ./server/win/winupdate.nix
          # ./server/cloud/cloud.nix
          # ./server/cloud/nextcloud.nix
          # ./server/secret/vaultwarden.nix
          # ./server/mail/maddy-admin.nix
          # ./server/message/tuwunel.nix
          # ./server/message/element-web.nix
          # ./server/monitoring/prometheus.nix
          # ./server/bookmarks/readeck.nix
          # ./server/translate/libretranslate-container.nix
          # ./server/share/smbgate.nix
          # ./server/mail/bichon.nix
          # ./server/cloud/nextcloud-container-authelia.nix
          # ./server/todo/vikunja-authelia.nix
          # ./server/pki/vaultls-docker-authelia.nix
          # ./server/office/onlyoffice-container.nix
          # ./server/lora/meshtastic-web.nix
        ];
      };
      srv2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          ./storage/stateless-luks-sequence.nix
          ./configuration.nix
          ./hardware/all.nix
          ./client/addrootCA.nix
          ./client/addCache.nix
          ./person/desktop/mpaepcke.nix
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
          ./hardware/all-gpu.nix
          ./client/addrootCA.nix
          ./client/addCache.nix
          ./client/addYubilock.nix
          ./openwrt/alias.nix
          ./openwrt/tftp.nix
          ./person/desktop/mpaepcke.nix
          ./packages/desktop/gnome.nix
          ./packages/desktop/add-onlyoffice.nix
          ./packages/desktop/add-av.nix
          ./packages/base.nix
          ./packages/devops-all.nix
          ./server/bookmarks/readeck.nix
          ./server/cache/ncps.nix
          ./server/cloud/cloud.nix
          ./server/cloud/nextcloud.nix
          ./server/dns/bind.nix
          ./server/dns/adguard.nix
          ./server/iam/authelia.nix
          ./server/iam/lldap.nix
          ./server/log/syslog-ng.nix
          ./server/mail/maddy-admin.nix
          ./server/message/tuwunel.nix
          # ./server/monitoring/grafana.nix
          ./server/monitoring/prometheus.nix
          ./server/ocr/paperless-ngx-authelia.nix
          ./server/search/searx.nix
          ./server/secret/vaultwarden.nix
          ./server/soc/chef.nix
          ./server/it/rackula.nix
          ./server/pki/small-step.nix
          ./server/pki/certwarden.nix
          ./server/pki/mkcertweb.nix
          ./server/portal/homer-home-container.nix
          ./server/webapp/res.nix
          ./server/webapp/test.nix
          ./server/cloud/nextcloud.nix
          ./server/rss/miniflux-container-authelia.nix
          ./server/media/immich-container-authelia.nix
          ./server/ocr/paperless-ngx-authelia.nix
          ./server/portal/glance.nix
          ./server/it/networking-toolbox.nix
          ./server/it/web-check.nix
          ./server/search/websurfx-systemd.nix
          ./server/sip/coturn.nix
          ./server/message/tuwunel.nix
          ./server/share/dumbdrop.nix
          ./hosts/srv.nix
          ./server/db/undb-docker.nix
          ./server/translate/libretranslate-container.nix
          ./server/share/smbgate.nix
          ./server/office/onlyoffice-container.nix
          ./server/lora/meshtastic-web.nix
          ./server/pki/vaultls-docker-authelia.nix
          ./server/translate/libretranslate-container.nix
          ./server/share/smbgate.nix
          ./server/mail/maddy-admin.nix
          ./server/office/onlyoffice-container.nix
          ./server/lora/meshtastic-web.nix
          ./server/ai/open-webui-container-authelia.nix
          # ./server/office/bentopdf.nix
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
          ./server/all/libretranslate-container.nix
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
