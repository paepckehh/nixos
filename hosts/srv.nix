{
  config,
  pkgs,
  lib,
  infra,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../storage/stateless-luks-fixed-6F6B-6565.nix
    ../hardware/all.nix
    ../role/adm.nix
    ../role/server.nix
    ../openwrt/alias.nix
    ../person/desktop/mpaepcke.nix
    ../packages/base.nix
    ../packages/devops.nix
    ../packages/desktop/gnome.nix
    ../server/dns/bind.nix
    ../server/infra/ncps.nix
    ../server/infra/git-mirror-scripts.nix
    ../server/infra/git-mirror-container.nix
    ../server/infra/syslog-ng.nix
    ../server/search/searx.nix
    ../server/pki/small-step.nix
    ../server/portal/portal-start.nix
    ../server/webapp/res.nix
    # ../server/iam/authelia.nix
    # ../server/iam/lldap.nix
    # ../server/lora/meshtastic-web.nix
    # ../server/remote/rustdesk.nix
    # ../server/api/openpaq.nix
    # ../server/api/osm.nix
    # ../server/ai/crush.nix
    # ../server/ai/ollama01.nix
    # ../server/remote/guacamole.nix
    # ../server/mail/maddy-admin.nix
    # ../server/bookmarks/readeck.nix
    # ../server/mail/autoconfig-admin.nix
    # ../server/win/winstart.nix
    # ../server/win/winupdate.nix
    # ../server/db/undb.nix
    # ../server/cloud/cloud.nix
    # ../server/cloud/nextcloud.nix
    # ../server/secret/vaultwarden.nix
    # ../server/message/tuwunel.nix
    # ../server/message/element-web.nix
    # ../server/monitoring/prometheus.nix
    # ../server/share/smbgate.nix
    # ../server/mail/bichon.nix
  ];

  ##############
  # NETWORKING #
  ##############
  networking = {
    extraHosts = "${infra.srv.user.ip} ${infra.srv.hostname} ${infra.srv.user.fqdn}";
    hostName = lib.mkForce infra.srv.name;
    hostId = lib.mkForce infra.srv.hostID;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.enable = lib.mkForce infra.srv.reverseproxy;
    openssh = {
      enable = lib.mkForce infra.srv.sshd;
      listenAddresses = lib.mkForce [
        {
          addr = infra.srv.admin.ip;
          port = infra.port.ssh-mgmt;
        }
      ];
    };
  };

  ###########
  # SYSTEMD #
  ###########
  systemd = {
    network.networks = {
      "${infra.namespace.admin}" = {
        enable = lib.mkForce true;
        addresses = [{Address = "${infra.srv.admin.ip}/${toString infra.cidr.netmask}";}];
      };
      "${infra.namespace.user}" = {
        enable = lib.mkForce true;
        addresses = [{Address = "${infra.srv.user.ip}/${toString infra.cidr.netmask}";}];
      };
      "${infra.namespace.container}" = {
        enable = lib.mkForce true;
      };
      "${infra.namespace.container}-dummy0" = {
        enable = lib.mkForce true;
      };
    };
  };
}
