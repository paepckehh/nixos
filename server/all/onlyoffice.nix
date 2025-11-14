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
    onlyoffice = {
      id = 132;
      name = "onlyoffice";
      hostname = infra.onlyoffice.name;
      domain = infra.domain.user;
      fqdn = "${infra.onlyoffice.hostname}.${infra.onlyoffice.domain}";
      ip = "${infra.net.user}.${toString infra.onlyoffice.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost;
        port.http = infra.localhostPortOffset + infra.onlyoffice.id;
      };
    };
  };
in {
  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      onlyoffice = {
        file = ../../modules/resources/onlyoffice.age;
        owner = "onlyoffice";
        group = "onlyoffice";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups.onlyoffice = {};
    users = {
      onlyoffice = {
        group = "onlyoffice";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh authentication
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.onlyoffice.namespace}.addresses = [
    {Address = "${infra.onlyoffice.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.onlyoffice.ip} ${infra.onlyoffice.hostname} ${infra.onlyoffice.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    onlyoffice = {
      enable = true;
      hostname = infra.onlyoffice.localbind.ip;
      port = infra.onlyoffice.localbind.port.http;
      jwtSecretFile = config.age.secrets.onlyoffice.path;
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.onlyoffice.fqdn}".extraConfig = ''
        bind ${infra.onlyoffice.ip}
        reverse_proxy ${infra.onlyoffice.localbind.ip}:${toString infra.matrix.localbind.ports.http}
        @not_intranet { not remote_ip ${infra.onlyoffice.network} }
        respond @not_intranet 403'';
    };
  };
}
