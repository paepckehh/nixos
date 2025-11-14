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
        name = infra.site.name; # home
        extern = "paepcke.de";
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
    email.domain = {
      intern = infra.domain.user;
      extern = infra.site.domain.extern;
    };
    admin = {
      name = "admin";
      displayName = "IT-TEAM@${infra.site.site.cloudName.admin}";
      email = "it@${infra.email.domain.intern}";
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
    zonename = {
      admin = "adm";
      user = infra.site.name;
      remote = "remote";
    };
    domain = {
      tld = infra.site.domain.tld; # tld => .corp
      domain = "${infra.domain.tld}"; # not used, domain = tld => .corp
      admin = "${infra.zonename.admin}.${infra.domain.tld}"; # result => dns-zone adm.corp
      user = "${infra.zonename.user}.${infra.domain.tld}"; # result => dns-zone home.corp
      remote = "${infra.zonename.remote}.${infra.domain.tld}"; # result => dnz-sone remote.corp
    };
    namespace = {
      prefix = "";
      admin = "${infra.namespace.prefix}${toString infra.id.admin}";
      user = "${infra.namespace.prefix}${toString infra.id.user}";
      remote = "${infra.namespace.prefix}${toString infra.id.remote}";
    };
    port = {
      smtp = 25;
      dns = 53;
      http = 80;
      imap = 143;
      jmap = 143;
      syslog = 514;
      https = 443;
      ldap = 3890;
      webapps = [infra.port.http infra.port.https];
    };
    proxies = {
      http = [];
      https = [];
    };
    opn = {
      name = "bug";
      logo = "https://res.${infra.domain.user}/icon/png/${infra.it.name}.png";
      standby = ["01"];
      infra = ["02" "03"];
      firewall = ["11" "12" "13"];
      adminport = {
        https = "8443";
        ssh = "6622";
      };
    };
    smtp = {
      id = 25;
      hostname = "smtp";
      domain = infra.domain.user;
      fqdn = "${infra.smtp.hostname}.${infra.smtp.domain}";
      ip = "${infra.net.user}.${toString infra.smtp.id}";
      uri = "smtp://${infra.smtp.fqdn}:${toString infra.port.smtp}";
      access.cidr = infra.cidr.user;
      extern.domain = infra.site.domain.extern;
    };
    # auto configure imap, jmap, smtp, thunderbird
    # https://www.ietf.org/archive/id/draft-ietf-mailmaint-autoconfig-00.html#name-formal-definition
    autoconfig = {
      id = 26;
      hostname = "autoconfig";
      domain = infra.domain.user;
      fqdn = "${infra.autoconfig.hostname}.${infra.autoconfig.domain}";
      ip = "${infra.net.user}.${toString infra.autoconfig.id}";
      access.cidr = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.autoconfig.id;
      auth = {
        authentication = "password-cleartext"; # password-cleartext; none; other see doc
        id = "%EMAILADDRESS%"; #   %EMAILADDRESS% ;  %EMAILLOCALPART%
        socketType = "plain"; # SSL ; STARTTLS ; plain
      };
    };
    webmail = {
      id = 27;
      hostname = "webmail";
      domain = infra.domain.user;
      fqdn = "${infra.webmail.hostname}.${infra.webmail.domain}";
      ip = "${infra.net.user}.${toString infra.webmail.id}";
      access.cidr = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.webmail.id;
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
      access.cidr = infra.cidr.all;
      localbind.port.http = infra.localhost.port.offset + infra.cache.id;
      cacheSize = "50G";
      pubkey.url = "https://${infra.cache.fqdn}/pubkey"; # generated
    };
    it = {
      id = 56;
      name = "it";
      hostname = infra.it.name;
      domain = infra.domain.user;
      fqdn = "${infra.it.hostname}.${infra.it.domain}";
      ip = "${infra.net.user}.${toString infra.it.id}";
      access.cidr = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.it.id;
    };
    ldap = {
      id = 86;
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
      base = "dc=${infra.zonename.user},dc=${infra.domain.tld}";
      baseDN = "ou=people,${infra.ldap.base}";
      bind = {
        dn = "uid=bind,${infra.ldap.baseDN}";
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
    sso = {
      id = 87;
      name = "authelia";
      site = infra.site.name;
      hostname = "sso";
      domain = infra.domain.user;
      fqdn = "${infra.sso.hostname}.${infra.sso.domain}";
      ip = "${infra.net.user}.${toString infra.sso.id}";
      url = "https://${infra.sso.fqdn}";
      callbackUrl = "${infra.sso.url.base}/api/auth/oidc/callback";
      access.cidr = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.sso.id;
    };
    syslog = {
      id = 100;
      name = "syslog";
      hostname = infra.syslog.name;
      admin = {
        domain = infra.domain.admin;
        fqdn = "${infra.syslog.hostname}.${infra.syslog.admin.domain}";
        ip = "${infra.net.admin}.${toString infra.syslog.id}";
      };
      user = {
        domain = infra.domain.admin;
        fqdn = "${infra.syslog.hostname}.${infra.syslog.user.domain}";
        ip = "${infra.net.user}.${toString infra.syslog.id}";
      };
      remote = {
        domain = infra.domain.remote;
        fqdn = "${infra.syslog.hostname}.${infra.syslog.user.remote}";
        # ip = "${infra.net.user}.${toString infra.syslog.id}";
        ip = "192.168.80.100";
      };
    };
    pki = {
      id = 108;
      name = "pki";
      hostname = infra.pki.name;
      domain = infra.domain.admin;
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      ip = "${infra.net.admin}.${toString infra.pki.id}";
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
    status = {
      id = 110;
      name = "status";
      hostname = infra.status.name;
      domain = infra.domain.user;
      fqdn = "${infra.status.hostname}.${infra.status.domain}";
      ip = "${infra.net.user}.${toString infra.status.id}";
      access.cidr = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.status.id;
      url = "https://${infra.status.fqdn}";
      logo = "https://res.${infra.domain.user}/icon/png/healthchecks.png";
    };
    monitoring = {
      id = 111;
      name = "monitoring";
      hostname = infra.monitoring.name;
      domain = infra.domain.user;
      fqdn = "${infra.monitoring.hostname}.${infra.monitoring.domain}";
      ip = "${infra.net.user}.${toString infra.monitoring.id}";
      access.cidr = infra.cidr.user;
      localbind.port.http = infra.localhost.port.offset + infra.monitoring.id;
      url = "https://${infra.monitoring.fqdn}";
      logo = "https://res.${infra.domain.user}/icon/png/healthchecks.png";
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
      url = "https://${infra.cloud.fqdn}";
      logo = "https://res.${infra.domain.user}/icon/png/nextcloud-blue.png";
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
      localbind.port.http = infra.localhost.port.offset + infra.search.id;
      url = "https://${infra.search.fqdn}";
      logo = "https://res.${infra.domain.user}/icon/png/searxng.png";
    };
    webarchiv = {
      id = 130;
      name = "webarchiv";
      hostname = infra.webarchiv.name;
      domain = infra.domain.user;
      fqdn = "${infra.webarchiv.hostname}.${infra.webarchiv.domain}";
      ip = "${infra.net.user}.${toString infra.webarchiv.id}";
      access.cidr = infra.cidr.user;
      localbind.ports.http = infra.localhost.port.offset + infra.webarchiv.id;
      url = "https://${infra.webarchiv.fqdn}";
      logo = "https://res.${infra.domain.user}/icon/png/readeck.png";
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
      logo = "https://res.${infra.domain.user}/icon/png/homer.png";
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
    imap = {
      id = 143;
      hostname = "imap";
      domain = infra.domain.user;
      fqdn = "${infra.imap.hostname}.${infra.imap.domain}";
      ip = "${infra.net.user}.${toString infra.imap.id}";
      access.cidr = infra.cidr.user;
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
