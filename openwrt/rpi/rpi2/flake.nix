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
        hostname = "rpi2b";
        soc = "rpi-2";
        version = "24.10.0";
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
