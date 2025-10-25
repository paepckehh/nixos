let
  infra = {
    site = {
      id = 50;
      name = "home";
      domain = {
        tld = "corp";
        name = infra.site.name; # result => scope <intranet> *.home.corp
        extern = "paepcke.de"; # result => scope <internet> *.paepcke.de
      };
      networkrange = {
        oct1 = 10; # prefix
        oct2 = infra.site.id; # result => scope <intranet> 10.50.0.0/16
      };
      cloudName = {
        admin = "IT-ADMIN-HOMECLOUD";
        user = "HOMECLOUD";
      };
    };
    admin = {
      name = "admin";
      displayName = "IT-TEAM@${infra.site.site.cloudName.admin}";
      email = "it@${infra.smtp.extern.domain}";
    };
    localhost = {
      name = "localhost";
      ip = "127.0.0.1";
      port.offset = 7000;
    };
    metric.port.offset = 9000;
    id = {
      admin = 0;
      user = 6;
      remote = 66;
    };
    vlan = {
      admin = infra.id.admin;
      user = infra.id.user;
      remote = infra.id.remote;
    };
    net = {
      prefix = "${toString infra.site.networkrange.oct1}.${toString infra.site.networkrange.oct2}";
      admin = "${infra.net.prefix}.${toString infra.id.admin}";
      user = "${infra.net.prefix}.${toString infra.id.user}";
      remote = "${infra.net.prefix}.${toString infra.id.remote}";
    };
    cidr = {
      netmask = 23; # result => /23 => 255.255.254.0 => 512 ip/net
      admin = "${infra.net.admin}.0/${toString infra.cidr.netmask}"; # result => network admin  10.50.0.0/23
      user = "${infra.net.user}.0/${toString infra.cidr.netmask}"; # result => network user   10.50.6.0/23
      remote = "${infra.net.remote}.0/${toString infra.cidr.netmask}"; # result => network remote 10.50.66.0/23
      all = "${infra.cidr.admin} ${infra.cidr.user} ${infra.cidr.remote}";
      clients = "${infra.cidr.user} ${infra.cidr.remote}";
      allArray = [infra.cidr.admin infra.cidr.user infra.cidr.remote];
      clientsArray = [infra.cidr.user infra.cidr.remote];
    };
    domain = {
      tld = infra.site.domain.tld;
      domain = "${infra.site.domain.name}.${infra.domain.tld}"; # result => dns-zone home.corp
      admin = "admin.${infra.domain.domain}"; # result => dns-zone admin.home.corp
      user = "user.${infra.domain.domain}"; # result => dns-zone user.home.corp
      remote = "remote.${infra.domain.domain}"; # result => dnz-sone remote.home.corp
    };
    namespace = {
      prefix = "net";
      admin = "${infra.namespace.prefix}-${toString infra.id.admin}";
      user = "${infra.namespace.prefix}-${toString infra.id.user}";
      remote = "${infra.namespace.prefix}-${toString infra.id.remote}";
    };
    port = {
      dns = 53;
      smtp = 25;
      imap = 143;
      ldap = 3890;
      http = 80;
      https = 443;
      webapps = [infra.port.http infra.port.https];
    };
    pki = {
      acmeContact = infra.admin.email;
      caFile = "/etc/ca.crt";
      hostname = "pki";
      domain = infra.domain.user;
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      url = "https://${infra.pki.fqdn}/acme/acme/directory";
    };
    smtp = {
      hostname = "smtp";
      port = infra.port.smtp;
      domain = infra.domain.admin;
      fqdn = "${infra.smtp.hostname}.${infra.smtp.domain}";
      extern.domain = infra.site.domain.extern;
    };
    ldap = {
      id = 126;
      name = "ldap";
      hostname = infra.ldap.name;
      domain = infra.domain.user;
      access.cidr = infra.cidr.all;
      fqdn = "${infra.ldap.hostname}.${infra.ldap.domain}";
      ip = "${infra.net.user}.${toString infra.ldap.id}";
      port = infra.port.ldap;
      url = "http://${infra.ldap.ip}:${toString infra.ldap.port}";
      uri = "ldap://${infra.ldap.ip}:${toString infra.ldap.port}";
      base = "dc=${infra.domain.domain},dc=${infra.domain.tld}";
      bind = {
        dn = "cn=bind,ou=persons,${infra.ldap.base}";
        pwd = "startbind";
      };
    };
    iam = {
      id = infra.ldap.id;
      name = "iam"; # ldap-web-gui
      hostname = infra.iam.name;
      domain = infra.domain.user;
      access.cidr = infra.cidr.all;
      fqdn = "${infra.iam.hostname}.${infra.iam.domain}";
      url = "https://${infra.iam.fqdn}";
      ip = "${infra.net.user}.${toString infra.iam.id}";
      ports = infra.ports.webapps;
      localbind.port = infra.localhost.port.offset + infra.iam.id;
    };
    dns = {
      id = 53;
      name = "dns";
      hostname = infra.dns.name;
      domain = infra.domain.user;
      fqdn = "${infra.dns.hostname}.${infra.dns.domain}";
      port = infra.port.dns;
      ip = "${infra.net.user}.${toString infra.dns.id}";
      access = infra.cidr.all;
      accessArray = infra.cidr.allArray;
      namespace = infra.namespace.user;
    };
  };
in {infra = infra;}
