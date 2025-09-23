{config, ...}: let
  infra = {
    admin = "admin";
    contact = "it@${infra.smtp.maildomain}";
    localhost = "127.0.0.1";
    localhostPortOffset = 7000;
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
      uri = "http://10.20.0.126:3890";
      base = "dc=dbt,dc=corp";
      bind.dn = "cn=bind,ou=persons,${infra.ldap.base}";
    };
    matrix = {
      id = 128;
      name = "matrix";
      ldap = true;
      self-register = {
        enable = true;
        password = "start";
      };
      hostname = infra.matrix.name;
      domain = infra.domain.user;
      fqdn = "${infra.matrix.hostname}.${infra.matrix.domain}";
      ip = "${infra.net.user}.${toString infra.matrix.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost;
        port.http = infra.localhostPortOffset + infra.matrix.id;
      };
    };
  };
in {
  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      tuwunel = {
        file = ../../modules/resources/matrix.age;
        owner = "tuwunel";
        group = "tuwunel";
      };
      tuwunel-ldap-bind = {
        file = ../../modules/resources/bind.age;
        owner = "tuwunel";
        group = "tuwunel";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.tuwunel = {};
    users = {
      tuwunel = {
        group = "tuwunel";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.matrix.namespace}.addresses = [
    {Address = "${infra.matrix.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.matrix.ip} ${infra.matrix.hostname} ${infra.matrix.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    matrix-tuwunel = {
      enable = true;
      settings = {
        global = {
          address = [infra.matrix.localbind.ip];
          port = [infra.matrix.localbind.port.http];
          server_name = infra.matrix.fqdn;
          allow_encryption = false;
          allow_federation = false;
          allow_registration = infra.matrix.self-register.enable;
          registration_token = infra.matrix.self-register.password;
          rocksdb_compression_algo = "zstd";
          ldap = {
            enable = infra.matrix.ldap;
            uri = infra.ldap.uri;
            bind_dn = infra.ldap.bind.dn;
            bind_password_file = config.age.secrets.tuwunel-ldap-bind.path;
            filter = "(objectClass=*)";
            uid_attribute = "uid";
            mail_attribute = "mail";
            name_attribute = "givenName";
          };
        };
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.matrix.fqdn}".extraConfig = ''
        bind ${infra.matrix.ip}
        reverse_proxy ${infra.matrix.localbind.ip}:${toString infra.matrix.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.matrix.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.matrix.name}.log
        }'';
    };
  };
}
