let
  infra = {
    site = {
      id = 50; # site/company id, range 1-256
      name = "home"; # site/company name
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
      id = 108;
      name = "pki";
      hostname = infra.pki.name;
      domain = infra.domain.admin;
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      ip = "${infra.net.admin}.${toString infra.pki.id}";
      port = infra.port.webapps;
      access.cidr = infra.cidr.admin;
      url = "https://${infra.pki.fqdn}";
      certs.rootCA = {
        content = ''
          ### X509 CERT
        '';
        name = "rootCA.crt";
        path = "/etc/${infra.pki.certs.rootCA.name}";
      };
      acme = {
        contact = infra.admin.email;
        url = "https://${infra.pki.fqdn}/acme/acme/directory";
      };
    };
    smtp = {
      id = 25;
      hostname = "smtp";
      domain = infra.domain.user;
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      ip = "${infra.net.user}.${toString infra.ldap.id}";
      port = infra.port.smtp;
      access.cidr = infra.cidr.all;
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
      fqdn = "${infra.iam.hostname}.${infra.iam.domain}";
      ip = "${infra.net.user}.${toString infra.iam.id}";
      ports = infra.ports.webapps;
      url = "https://${infra.iam.fqdn}";
      access.cidr = infra.cidr.all;
      localbind.port.http = infra.localhost.port.offset + infra.iam.id;
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
      upstream = ["192.168.80.1"];
    };
    webacme = {
      id = 151;
      name = "acme";
      hostname = infra.webacme.name;
      domain = infra.domain.admin;
      fqdn = "${infra.webacme.hostname}.${infra.webacme.domain}";
      ip = "${infra.net.admin}.${toString infra.webacme.id}";
      port = infra.port.webapps;
      access.cidr = infra.cidr.admin;
      url = "https://${infra.webacme.fqdn}";
      localbind.port.http = infra.localhost.port.offset + infra.webacme.id;
    };
    webpki = {
      id = 152;
      name = "webpki";
      hostname = infra.webpki.name;
      domain = infra.domain.admin;
      fqdn = "${infra.webpki.hostname}.${infra.webpki.domain}";
      ip = "${infra.net.admin}.${toString infra.webpki.id}";
      port = infra.port.webapps;
      access.cidr = infra.cidr.admin;
      url = "https://${infra.webpki.fqdn}";
      localbind.port.http = infra.localhost.port.offset + infra.webpki.id;
    };
  };
in {infra = infra;}
