{
  config,
  pkgs,
  ...
}: let
  infra = {
    admin = "admin";
    contact = "it@${infra.smtp.maildomain}";
    localhost = {
      ip = "127.0.0.1";
      port.offset = {
        http = 7000;
        app = 8000;
        metrics = 9000;
      };
    };
    id = {
      admin = 0;
      user = 6;
    };
    port = {
      smtp = 25;
      http = 80;
      https = 443;
      webapp = [infra.port.http infra.port.https];
    };
    domain = {
      tld = "corp";
      admin = "adm.${infra.domain.tld}";
      user = "dbt.${infra.domain.tld}";
    };
    cidr = {
      admin = "${infra.net.user}.0/24";
      user = "${infra.net.user}.0/23";
    };
    net = {
      prefix = "10.20";
      admin = "${infra.net.prefix}.${toString infra.id.admin}";
      user = "${infra.net.prefix}.${toString infra.id.user}";
    };
    namespace = {
      admin = "${toString infra.id.admin}";
      user = "${toString infra.id.user}";
    };
    pki = {
      acmeContact = "acme@${infra.pki.fqdn}";
      caFile = "/etc/ca.crt";
      hostname = "pki";
      domain = infra.domain.admin;
      maildomain = "debitor.de";
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      url = "https://${infra.pki.fqdn}/acme/acme/directory";
    };
    smtp = {
      hostname = "smtp";
      domain = infra.domain.admin;
      fqdn = "${infra.smtp.hostname}.${infra.smtp.domain}";
      maildomain = "debitor.de";
    };
    ldap = {
      id = 144;
      name = "ldap";
      hostname = infra.ldap.name;
      domain = infra.domain.user;
      fqdn = "${infra.ldap.hostname}.${infra.ldap.domain}";
      uri = "http://${infra.fqdn}:3890";
      base = "dc=${infra.domain.user},dc=${infra.domain.tld}";
      bind.dn = "cn=bind,ou=persons,${infra.ldap.base}";
    };
    mopidy = {
      id = 149;
      name = "mopidy";
      hostname = infra.mopidy.name;
      domain = infra.domain.user;
      fqdn = "${infra.mopidy.hostname}.${infra.mopidy.domain}";
      ip = "${infra.net.user}.${toString infra.mopidy.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost.ip;
        port.http = infra.localhost.port.offset.http + infra.mopidy.id;
        port.mpd = infra.localhost.port.offset.app + infra.mopidy.id;
      };
    };
  };
in {
  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.mopidy = {};
    users = {
      mopidy = {
        group = "mopidy";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.mopidy.namespace}.addresses = [
    {Address = "${infra.mopidy.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.mopidy.ip} ${infra.mopidy.hostname} ${infra.mopidy.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    mopidy = {
      enable = true;
      extensionPackages = with pkgs; [mopidy-spotify mopidy-iris mopidy-tidal mopidy-tunein mopidy-youtube mopidy-podcast mopidy-soundcloud];
      settings = {
        mpd = {
          enabled = true;
          hostname = infra.mopidy.localbind.ip;
          port = infra.mopidy.localbind.port.mpd;
        };
        http = {
          enabled = true;
          hostname = infra.mopidy.localbind.ip;
          port = infra.mopidy.localbind.port.http;
          zeroconf = ""; # disable
          csrf_protection = true;
          allowed_origins = ""; # disable, infra.mopidy.fqdn;
          default_app = "mopidy";
        };
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.mopidy.fqdn}".extraConfig = ''
        bind ${infra.mopidy.ip}
        reverse_proxy ${infra.mopidy.localbind.ip}:${toString infra.mopidy.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.mopidy.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.mopidy.name}.log
        }'';
    };
  };
}
