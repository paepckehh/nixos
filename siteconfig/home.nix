let
  infra = {
    site = {
      id = 50; # site/company id, range 1-256
      name = "home"; # site/company name
      displayName = "Home Labs Paepcke";
      type = "private"; # private, business, validation, mobile
      lang = "de";
      tz = "Europe/Berlin";
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
      smtp = {
        id = "it";
        pwd = "password";
      };
    };
    localhost = {
      name = "localhost";
      ip = "127.0.0.1";
      cidr = "127.0.0.0/24";
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
      clients = "${infra.cidr.user} ${infra.cidr.remote}";
      all = "${infra.cidr.admin} ${infra.cidr.user} ${infra.cidr.remote} ${infra.localhost.cidr}";
      allArray = [infra.cidr.admin infra.cidr.user infra.cidr.remote infra.localhost.cidr];
      clientsArray = [infra.cidr.user infra.cidr.remote infra.localhost.cidr];
    };
    domain = {
      tld = infra.site.domain.tld;
      domain = "${infra.domain.tld}"; # result => dns-zone corp
      admin = "adm.${infra.domain.domain}"; # result => dns-zone adm.corp
      user = "home.${infra.domain.domain}"; # result => dns-zone home.corp
      remote = "remote.${infra.domain.domain}"; # result => dnz-sone remote.corp
    };
    namespace = {
      prefix = "";
      admin = "${infra.namespace.prefix}${toString infra.id.admin}";
      user = "${infra.namespace.prefix}${toString infra.id.user}";
      remote = "${infra.namespace.prefix}${toString infra.id.remote}";
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
    proxies = {
      http = [];
      https = [];
    };
    smtp = {
      id = 25;
      hostname = "smtp";
      domain = infra.domain.user;
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      ip = "${infra.net.user}.${toString infra.ldap.id}";
      port = infra.port.smtp;
      uri = "smtp://${infra.smtp.fqdn}:${toString infra.smtp.port}";
      access.cidr = infra.cidr.all;
      extern.domain = infra.site.domain.extern;
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
      upstream = ["192.168.80.1"]; # XXX
      contact = "it.${infra.smtp.extern.domain}";
    };
    cache = {
      id = 55;
      name = "cache";
      hostname = infra.cache.name;
      domain = infra.domain.user;
      fqdn = "${infra.cache.hostname}.${infra.cache.domain}";
      ip = "${infra.net.user}.${toString infra.cache.id}";
      port = infra.port.webapps;
      access = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.cache.id;
      cacheSize = "50G";
      pubkey.url = "https://${infra.cache.fqdn}/pubkey"; # generated
    };
    pki = {
      id = 108;
      name = "pki";
      hostname = infra.pki.name;
      domain = infra.domain.admin;
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      ip = "${infra.net.admin}.${toString infra.pki.id}";
      port = infra.port.https;
      access.cidr = infra.cidr.admin;
      url = "https://${infra.pki.fqdn}";
      certs = {
        defaultTLSCertDuration = "1440h0m0s";
        rootCA = {
          content = ''
            ### X509 CERT
          '';
          name = "rootCA.crt";
          path = "/etc/${infra.pki.certs.rootCA.name}";
        };
      };
      acme = {
        contact = infra.admin.email;
        url = "https://${infra.pki.fqdn}/acme/acme/directory";
      };
    };
    cloud = {
      id = 117;
      name = "cloud";
      hostname = infra.cloud.name;
      domain = infra.domain.user;
      fqdn = "${infra.cloud.hostname}.${infra.cloud.domain}";
      ip = "${infra.net.user}.${toString infra.cloud.id}";
      port = infra.port.webapps;
      access.cidr = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.cloud.id;
    };
    search = {
      id = 119;
      name = "search";
      hostname = infra.search.name;
      domain = infra.domain.user;
      fqdn = "${infra.search.hostname}.${infra.search.domain}";
      ip = "${infra.net.user}.${toString infra.search.id}";
      port = infra.port.webapps;
      access.cidr = infra.cidr.user;
      url = "https://${infra.search.fqdn}";
      localbind.port.http = infra.localhost.port.offset + infra.search.id;
    };
    ldap = {
      id = 126;
      name = "ldap";
      package = "lldap";
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
      ports = infra.port.webapps;
      url = "https://${infra.iam.fqdn}";
      access.cidr = infra.cidr.all;
      localbind.port.http = infra.localhost.port.offset + infra.iam.id;
    };
    portal = {
      id = 135;
      name = "start";
      hostname = infra.portal.name;
      domain = infra.domain.user;
      fqdn = "${infra.portal.hostname}.${infra.portal.domain}";
      ip = "${infra.net.user}.${toString infra.portal.id}";
      access.cidr = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.portal.id;
      url = "https://${infra.portal.fqdn}";
    };
    res = {
      id = 141;
      name = "res";
      hostname = infra.res.name;
      domain = infra.domain.user;
      fqdn = "${infra.res.hostname}.${infra.res.domain}";
      ip = "${infra.net.user}.${toString infra.res.id}";
      access.cidr = infra.cidr.user;
      www.root = "/var/lib/caddy/res";
    };
    sso = {
      id = 143;
      name = "authelia";
      site = infra.site.name;
      hostname = "sso";
      domain = infra.domain.user;
      fqdn = "${infra.sso.hostname}.${infra.sso.domain}";
      ip = "${infra.net.user}.${toString infra.sso.id}";
      ports = infra.port.webapps;
      url = {
        base = "https://${infra.sso.fqdn}";
        callback = "${infra.sso.url.base}/api/auth/oidc/callback";
      };
      access.cidr = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.sso.id;
    };
    webacme = {
      id = 151;
      name = "webacme";
      hostname = infra.webacme.name;
      domain = infra.domain.admin;
      fqdn = "${infra.webacme.hostname}.${infra.webacme.domain}";
      ip = "${infra.net.admin}.${toString infra.webacme.id}";
      access.cidr = infra.cidr.admin;
      localbind.port.http = infra.localhost.port.offset + infra.webacme.id;
      url = "https://${infra.webacme.fqdn}";
    };
    webpki = {
      id = 152;
      name = "webpki";
      hostname = infra.webpki.name;
      domain = infra.domain.admin;
      fqdn = "${infra.webpki.hostname}.${infra.webpki.domain}";
      ip = "${infra.net.admin}.${toString infra.webpki.id}";
      access.cidr = infra.cidr.admin;
      localbind.port.http = infra.localhost.port.offset + infra.webpki.id;
      url = "https://${infra.webpki.fqdn}";
    };
    webmtls = {
      id = 153;
      name = "webmtls";
      hostname = infra.webmtls.name;
      domain = infra.domain.admin;
      fqdn = "${infra.webmtls.hostname}.${infra.webmtls.domain}";
      ip = "${infra.net.admin}.${toString infra.webmtls.id}";
      access.cidr = infra.cidr.admin;
      localbind.port.http = infra.localhost.port.offset + infra.webmtls.id;
      url = "https://${infra.webmtls.fqdn}";
    };
    translate-lama = {
      id = 154;
      name = "translate-lama";
      hostname = infra.translate-lama.name;
      domain = infra.domain.user;
      fqdn = "${infra.translate-lama.hostname}.${infra.translate-lama.domain}";
      ip = "${infra.net.user}.${toString infra.translate-lama.id}";
      access.cidr = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.translate-lama.id;
    };
    test = {
      id = 155;
      name = "test";
      hostname = infra.test.name;
      domain = infra.domain.user;
      fqdn = "${infra.test.hostname}.${infra.test.domain}";
      ip = "${infra.net.user}.${toString infra.test.id}";
      access.cidr = infra.cidr.user;
    };
    grist = {
      id = 156;
      name = "grist";
      hostname = infra.grist.name;
      domain = infra.domain.user;
      fqdn = "${infra.grist.hostname}.${infra.grist.domain}";
      ip = "${infra.net.user}.${toString infra.grist.id}";
      access.cidr = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.grist.id;
    };
  };
in {infra = infra;}
