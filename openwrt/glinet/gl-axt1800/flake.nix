{
  inputs = {
    nix.url = "github:nixos/nixpkgs/nixos-unstable";
    openwrt-imagebuilder.url = "git+file:/etc/nixos/openwrt/nix-openwrt-imagebuilder";
  };
  outputs = {
    self,
    nix,
    openwrt-imagebuilder,
  }: {
    ########################
    #-=# CONFIG-SECTION #=-#
    ########################
    packages.x86_64-linux."image" = let
      openwrt = {
        hostname = "axp";
        soc = "glinet_gl-axt1800";
        version = "snapshot"; # not in release yet
        admin = {
          password = "start";
          webui.port = "9292";
          ssh = {
            port = "6622";
            key.pub = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvG7XOtIqjA+zibUaFj9gz/zOKYkZ9gAuYmkHjbseCk age@paepcke.de";
          };
        };
        ntp = {
          server.enable = "0";
          timezone = "UTC";
          follow = "0.openwrt.pool.ntp.org' '1.openwrt.pool.ntp.org' '2.openwrt.pool.ntp.org' '3.openwrt.pool.ntp.org'";
        };
        monitor = {
          load.enable = "0";
          thermal.enable = "0";
          uplink = {
            enable = "0";
            targets = "8.8.8.8 9.9.9.9";
          };
        };
        wireless = {
          country = "DE";
          encryption = "sae";
          network = "lan";
          mode = "ap";
          htmode = "HT20";
          radio5G = {
            band = "5g";
            hwmode = "11a";
            require = "ac";
            path = "platform/soc/c000000.wifi";
            htmode = "${openwrt.wireless.htmode}";
            channel = "140"; # DFS
            net0 = {
              disabled = "1"; # XXX
              mode = "${openwrt.wireless.mode}";
              network = "${openwrt.wireless.network}";
              key = "start"; # XXX agenix build-time encryption
              encryption = "${openwrt.wireless.encryption}";
              ssid = "${openwrt.hostname}-${openwrt.wireless.radio5G.net0.mode}-${openwrt.wireless.radio5G.net0.network}-${openwrt.wireless.radio5G.band}-0";
            };
          };
          radio2G = {
            band = "2g";
            disabled = "1";
            hwmode = "11g";
            legacy = "1";
            path = "platform/soc/c000000.wifi+1";
            htmode = "${openwrt.wireless.htmode}";
            channel = "13";
            net0 = {
              disabled = "1"; # XXX
              mode = "${openwrt.wireless.mode}";
              network = "${openwrt.wireless.network}";
              key = "start"; # XXX agenix build-time encryption
              encryption = "${openwrt.wireless.encryption}";
              ssid = "${openwrt.hostname}-${openwrt.wireless.radio2G.net0.mode}-${openwrt.wireless.radio2G.net0.network}-${openwrt.wireless.radio2G.band}-0";
            };
          };
        };
      };
      ################################
      #-=# GENERIC-SHARED-BACKEND #=-#
      ################################
      pkgs = nix.legacyPackages.x86_64-linux;
      profiles = openwrt-imagebuilder.lib.profiles {inherit pkgs;};
      config =
        profiles.identifyProfile "${openwrt.soc}"
        // {
          release = "${openwrt.version}";
          extraImageName = "hard";
          device_packages = [
            "iperf3"
            "ntp-utils"
            "luci"
            "luci-app-advanced-reboot"
            "luci-app-statistics"
            "luci-app-wifischedule"
            "collectd-mod-ethstat"
            "collectd-mod-ipstatistics"
            "collectd-mod-load"
            "collectd-mod-ping"
            "collectd-mod-thermal"
            "collectd-mod-wireless"
          ];
          disabledServices = ["dropbear"];
          files = pkgs.runCommand "image-files" {} ''
            mkdir -p $out/etc/uci-defaults
            cat > $out/etc/uci-defaults/99-custom <<EOF
            uci -q batch << EOI
            set system.@system[0]=system
            set system.@system[0].hostname='${openwrt.hostname}'
            set system.@system[0].init='initiated'
            set system.@system[0].timezone='${openwrt.ntp.timezone}'
            set system.ntp=timeserver
            set system.ntp.server='${openwrt.ntp.follow}'
            set system.ntp.enabled='1'
            set system.ntp.enable_server='${openwrt.ntp.server.enable}'
            set dropbear.main=dropbear
            set dropbear.main.PasswordAuth='off'
            set dropbear.main.RootPasswordAuth='off'
            set dropbear.main.Port='${openwrt.admin.ssh.port}'
            set uhttpd.main=uhttpd
            set uhttpd.main.listen_http='127.0.0.1:80'
            set uhttpd.main.listen_https='${openwrt.admin.webui.port}'
            set uhttpd.main.redirect_https='1'
            set luci_statistics.collectd_thermal.enable='${openwrt.monitor.thermal.enable}'
            set luci_statistics.collectd_load.enable='${openwrt.monitor.thermal.enable}'
            set luci_statistics.collectd_network.enable='${openwrt.monitor.uplink.enable}'
            set luci_statistics.collectd_ping.enable='${openwrt.monitor.uplink.enable}'
            set luci_statistics.collectd_ping.Hosts='${openwrt.monitor.uplink.targets}'
            # 5GHz
            set wireless.radio0='wifi-device'
            set wireless.radio0.country='${openwrt.wireless.country}'
            set wireless.radio0.type='mac80211'
            set wireless.radio0.random_bssid='1'
            set wireless.radio1.require_mode='${openwrt.wireless.radio5G.require}'
            set wireless.radio0.band='${openwrt.wireless.radio5G.band}'
            set wireless.default_radio0.device='radio0'
            set wireless.default_radio0.mode='${openwrt.wireless.radio5G.net0.mode}'
            set wireless.default_radio0.key='${openwrt.wireless.radio5G.net0.key}'
            set wireless.default_radio0.encryption='${openwrt.wireless.radio5G.net0.encryption}'
            set wireless.default_radio0.ssid='${openwrt.wireless.radio5G.net0.ssid}'
            # 2GHz
            set wireless.radio1='wifi-device'
            set wireless.radio1.country='${openwrt.wireless.country}'
            set wireless.radio1.type='mac80211'
            set wireless.radio1.random_bssid='1'
            set wireless.radio1.legacy_rates='${openwrt.wireless.radio2G.legacy}'
            set wireless.radio1.band='${openwrt.wireless.radio2G.band}'
            set wireless.default_radio1.device='radio1'
            set wireless.default_radio1.mode='${openwrt.wireless.radio2G.net0.mode}'
            set wireless.default_radio1.key='${openwrt.wireless.radio2G.net0.key}'
            set wireless.default_radio1.encryption='${openwrt.wireless.radio2G.net0.encryption}'
            set wireless.default_radio1.ssid='${openwrt.wireless.radio2G.net0.ssid}'
            commit
            /usr/bin/passwd root <<EOP
            ${openwrt.admin.password}
            ${openwrt.admin.password}
            EOP
            EOI
            echo "${openwrt.admin.ssh.key.pub}" >> $out/etc/dropbear/authorized_keys
            EOF
          '';
        };
    in
      openwrt-imagebuilder.lib.build config;
  };
}
