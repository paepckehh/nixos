let
  ################
  #-=# INFRA  #=-#
  ################
  infra = {
    true = "true";
    false = "false";
    none = "none";
    one = "1";
    site = {
      id = 50; # site/company id, range 1-256
      name = "home"; # site/company name
      displayName = "Home Lab - Paepcke";
      type = "private"; # private, business, validation, mobile
      domain = {
        tld = "corp";
        name = infra.site.name;
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
    locale = {
      tz = "Europe/Berlin";
      lang = "de";
      defaultLocale = "C.UTF-8"; # "en_US.UTF-8" "de_DE.UTF-8;
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
      metric.offset = 9000;
    };
    id = {
      admin = 0;
      user = 6;
      remote = 66;
      virtual = 99;
    };
    vlan = {
      admin = infra.id.admin;
      user = infra.id.user;
      remote = infra.id.remote;
      virtual = infra.id.virtual;
    };
    net = {
      prefix = "${toString infra.site.networkrange.oct1}.${toString infra.site.networkrange.oct2}";
      admin = "${infra.net.prefix}.${toString infra.id.admin}";
      bridge = "10.255.254";
      user = "${infra.net.prefix}.${toString infra.id.user}";
      remote = "${infra.net.prefix}.${toString infra.id.remote}";
      virtual = "${infra.net.prefix}.${toString infra.id.virtual}";
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
      virtual = "virtual";
    };
    domain = {
      tld = infra.site.domain.tld; # tld => .corp
      domain = "${infra.domain.tld}"; # not used, domain = tld => .corp
      admin = "${infra.zonename.admin}.${infra.domain.user}"; # result => dns-zone adm.home.corp
      user = "${infra.zonename.user}.${infra.domain.tld}"; # result => dns-zone home.corp
      remote = "${infra.zonename.remote}.${infra.domain.tld}"; # result => dnz-zone remote.corp
      virtual = "${infra.zonename.virtual}.${infra.domain.tld}"; # result => dnz-zone remote.corp
    };
    namespace = {
      prefix = "";
      admin = "0${infra.namespace.prefix}${toString infra.id.admin}-admin";
      user = "0${infra.namespace.prefix}${toString infra.id.user}-user";
      remote = "${infra.namespace.prefix}${toString infra.id.remote}-remote";
    };
    container = {
      network = infra.net.virtual;
      interface = "br0";
    };
    port = {
      dns = 53;
      https = 443;
      smtp = 25;
      ssh = 6622;
      http = 80;
      imap = 143;
      jmap = 143;
      syslog = 514;
      ldap = 3890;
      smb = {
        quic = 443;
        tcp = 445;
      };
      webapps = [infra.port.http infra.port.https];
    };
    proxies = {
      http = [];
      https = [];
    };
    caldav = {
      name = "caldav";
      fqdn = "${infra.caldav.name}.${infra.domain.user}";
    };
    opn = {
      standby = ["01"];
      infra = ["02" "03"];
      firewall = ["11" "12" "13"];
      adminport = {
        https = "8443";
        ssh = "6622";
      };
      logo = "${infra.res.url}/icon/png/borg.png";
    };
    print = {
      app = "cups";
      # url = "https://drucker.${infra.domain.user}/printers";
      url = "http://localhost:631/";
      logo = "${infra.res.url}/icon/png/printer.png";
    };
    smbgate = {
      id = 24;
      name = "smbgate";
      hostname = infra.smbgate.name;
      domain = infra.domain.user;
      fqdn = "${infra.smbgate.hostname}.${infra.smbgate.domain}";
      ip = "${infra.net.user}.${toString infra.smbgate.id}";
      localbind.port.http = infra.localhost.port.offset + infra.smbgate.id;
      lock.interface = "user-vlan@br0";
      url = "https://${infra.smbgate.fqdn}";
      logo = "${infra.res.url}/icon/png/samba-server.png";
      # XXX samba users need statefull init - do additional: sudo sh ; smbpasswd -a <user>
      users = {
        "it" = {
          initialHashedPassword = null;
          openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
          description = "samba user for ti share";
          group = "ti";
          createHome = false;
          extraGroups = ["users"];
          isNormalUser = true;
        };
        "ti" = {
          initialHashedPassword = null;
          openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
          description = "samba user for ti share";
          group = "ti";
          createHome = false;
          extraGroups = ["users"];
          isNormalUser = true;
        };
        "fa" = {
          initialHashedPassword = null;
          openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"];
          description = "samba user for fa share";
          group = "fa";
          createHome = false;
          extraGroups = ["users"];
          isNormalUser = true;
        };
      };
      groups = {
        "it".members = ["it"];
        "ti".members = ["it"];
        "fa".members = ["fa"];
      };
      shares = {
        "it" = {
          "browseable" = "no";
          "comment" = "IT DataExchange";
          "path" = "/nix/persist/mnt/it";
          "writable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "it";
          "force group" = "it";
          "valid users" = "it";
        };
        "ti" = {
          "browseable" = "no";
          "comment" = "TI DataExchange";
          "path" = "/nix/persist/mnt/ti";
          "writable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "ti";
          "force group" = "i";
          "valid users" = "ti";
        };
        "fa" = {
          "browseable" = "no";
          "comment" = "FA DataExchange";
          "path" = "/nix/persist/mnt/fa";
          "writable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "fa";
          "force group" = "fa";
          "valid users" = "fa";
        };
      };
      mountpoints = [
        "d /nix/persist/mnt/it 0770 it it - -"
        "d /nix/persist/mnt/ti 0770 ti ti - -"
        "d /nix/persist/mnt/fa 0770 fa fa - -"
      ];
      mounts = {
      };
    };
    smtp = {
      id = 25;
      hostname = "smtp";
      domain = infra.smtp.user.domain;
      ip = infra.smtp.user.ip;
      fqdn = infra.smtp.user.fqdn;
      uri = infra.smtp.user.uri;
      admin = {
        domain = infra.domain.admin;
        fqdn = "${infra.smtp.hostname}.${infra.smtp.admin.domain}";
        ip = "${infra.net.admin}.${toString infra.smtp.id}";
        uri = "smtp://${infra.smtp.admin.fqdn}:${toString infra.port.smtp}";
        access.cidr = infra.cidr.admin;
      };
      user = {
        domain = infra.domain.user;
        fqdn = "${infra.smtp.hostname}.${infra.smtp.domain}";
        ip = "${infra.net.user}.${toString infra.smtp.id}";
        uri = "smtp://${infra.smtp.user.fqdn}:${toString infra.port.smtp}";
        access.cidr = infra.cidr.user;
      };
      external = {
        domain = infra.site.domain.extern;
        fqdn = "${infra.smtp.hostname}.${infra.smtp.external.domain}";
        ip = "192.168.21.125"; #
        uri = "smtp://${infra.smtp.external.ip}:${toString infra.port.smtp}";
        uriTcp = "tcp://${infra.smtp.external.ip}:${toString infra.port.smtp}";
        access.cidr = infra.cidr.user;
      };
    };
    # auto configure imap, jmap, smtp, thunderbird
    # https://www.ietf.org/archive/id/draft-ietf-mailmaint-autoconfig-00.html#name-formal-definition
    autoconfig = {
      id = 26;
      hostname = "autoconfig";
      localbind.port.http = infra.localhost.port.offset + infra.autoconfig.id;
      admin = {
        domain = infra.domain.admin;
        fqdn = "${infra.autoconfig.hostname}.${infra.autoconfig.admin.domain}";
        ip = "${infra.net.admin}.${toString infra.autoconfig.id}";
        auth = {
          authentication = "password-cleartext"; # password-cleartext; none; other see doc
          id = "%EMAILADDRESS%"; #   %EMAILADDRESS% ;  %EMAILLOCALPART%
          socketType = "plain"; # SSL ; STARTTLS ; plain
        };
      };
      user = {
        domain = infra.domain.user;
        fqdn = "${infra.autoconfig.hostname}.${infra.autoconfig.user.domain}";
        ip = "${infra.net.user}.${toString infra.autoconfig.id}";
        auth = {
          authentication = "password-cleartext";
          id = "%EMAILADDRESS%";
          socketType = "plain";
        };
      };
      external = {
        domain = infra.email.domain.extern;
        fqdn = "${infra.autoconfig.hostname}.${infra.autoconfig.external.domain}";
        ip = "${infra.net.user}.${toString infra.autoconfig.id}";
        auth = {
          authentication = "password-cleartext";
          id = "%EMAILADDRESS%";
          socketType = "plain";
        };
      };
    };
    webmail = {
      id = 27;
      hostname = "webmail";
      domain = infra.domain.user;
      fqdn = "${infra.webmail.hostname}.${infra.webmail.domain}";
      ip = "${infra.net.user}.${toString infra.webmail.id}";
      localbind.port.http = infra.localhost.port.offset + infra.webmail.id;
    };
    dns = {
      id = 53;
      name = "dns";
      resolver = {
        admin = {
          primary = "${infra.net.admin}.${toString infra.dns.id}";
          secondary = "${infra.net.admin}.${toString infra.dns.id}";
        };
        user = {
          primary = "${infra.net.user}.${toString infra.dns.id}";
          secondary = "${infra.net.user}.${toString infra.dns.id}";
        };
      };
      hostname = infra.dns.name;
      domain = infra.domain.user;
      fqdn = "${infra.dns.hostname}.${infra.dns.domain}";
      port = infra.port.dns;
      ip = "${infra.net.user}.${toString infra.dns.id}";
      access = infra.cidr.all;
      accessArray = infra.cidr.allArray;
      upstream = ["192.168.80.1" "192.168.90.250" "192.168.100.250" "192.168.40.250" "10.20.6.2" "10.20.0.2"]; # XXX
      contact = "it.${infra.smtp.external.domain}";
    };
    adguard = {
      id = infra.dns.id;
      app = "adguard-home";
      name = "adguard";
      hostname = infra.adguard.name;
      domain = infra.domain.admin;
      fqdn = "${infra.adguard.hostname}.${infra.adguard.domain}";
      ip = "${infra.net.admin}.${toString infra.adguard.id}";
      localbind.port.http = infra.localhost.port.offset + infra.adguard.id;
      filter_lists = [
        "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        "https://easylist.to/easylist/easylist.txt"
        "https://easylist.to/easylistgermany/easylistgermany.txt"
        "https://easylist-downloads.adblockplus.org/antiadblockfilters.txt"
        "https://secure.fanboy.co.nz/fanboy-annoyance.txt"
      ];
      user_rules = [
        "@@||bahn.de^$important"
      ];

      upstream_dns = [
        "sdns://AQcAAAAAAAAADjIzLjE0MC4yNDguMTAwIFa3zBQNs5jjEISHskpY7WSNK4sLj_qrbFiLk5tSBN1uGTIuZG5zY3J5cHQtY2VydC5kbnNjcnkucHQ"
        "sdns://AQcAAAAAAAAADzE0Ny4xODkuMTQwLjEzNiCL7wgLXnE-35sDhXk5N1RNpUfWmM2aUBcMFlst7FPdnRkyLmRuc2NyeXB0LWNlcnQuZG5zY3J5LnB0"
        "sdns://AQcAAAAAAAAADDIzLjE4NC40OC4xOSCwg3q2XK6z70eHJhi0H7whWQ_ZWQylhMItvqKpd9GtzRkyLmRuc2NyeXB0LWNlcnQuZG5zY3J5LnB0"
        "sdns://AQcAAAAAAAAADzE3Ni4xMTEuMjE5LjEyNiDzuja5nmAyDvA5jakqkuLQEtb245xsAhNwJYDLkKraKhkyLmRuc2NyeXB0LWNlcnQuZG5zY3J5LnB0"
      ];
      url = "https://${infra.adguard.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.adguard.app}.png";
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
      url = "https://${infra.cache.fqdn}";
      size = "100G";
      key = {
        url = "${infra.cache.url}/pubkey";
        pub = "cache:aFde6/c1Vz93N1XGGrvt/7NlUNdAyV35CgBUXKzyhyU=";
      };
    };
    it = {
      id = 56;
      name = "it";
      hostname = infra.it.name;
      domain = infra.domain.user;
      fqdn = "${infra.it.hostname}.${infra.it.domain}";
      ip = "${infra.net.user}.${toString infra.it.id}";
      localbind.port.http = infra.localhost.port.offset + infra.it.id;
    };
    proxmox = {
      id = 57;
      app = "proxmox";
      name = infra.proxmox.app;
      hostname = infra.proxmox.name;
      domain = infra.domain.admin;
      fqdn = "${infra.proxmox.hostname}.${infra.proxmox.domain}";
      ip = "${infra.net.admin}.${toString infra.proxmox.id}";
      localbind.port.http = infra.localhost.port.offset + infra.proxmox.id;
      url = "https://${infra.proxmox.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.proxmox.app}.png";
    };
    ldap = {
      id = 86;
      app = "lldap";
      name = "ldap";
      hostname = infra.ldap.name;
      domain = infra.domain.admin;
      fqdn = "${infra.ldap.hostname}.${infra.ldap.domain}";
      ip = "${infra.net.admin}.${toString infra.ldap.id}";
      port = infra.port.ldap;
      url = "http://${infra.ldap.ip}:${toString infra.ldap.port}";
      uri = "ldap://${infra.ldap.ip}:${toString infra.ldap.port}";
      uriHost = "ldap://${infra.ldap.ip}";
      base = "dc=${infra.zonename.user},dc=${infra.domain.tld}";
      baseDN = "ou=people,${infra.ldap.base}";
      bind = {
        dn = "uid=bind,${infra.ldap.baseDN}";
        pwd = "startbind"; # public bind
      };
    };
    iam = {
      id = infra.ldap.id;
      app = "lldap";
      name = "iam";
      hostname = infra.iam.name;
      domain = infra.domain.user;
      fqdn = "${infra.iam.hostname}.${infra.iam.domain}";
      ip = "${infra.net.user}.${toString infra.iam.id}";
      ports = infra.port.webapps;
      access.cidr = infra.cidr.all;
      localbind.port.http = infra.localhost.port.offset + infra.iam.id;
      url = "https://${infra.iam.fqdn}";
      logo = "${infra.res.url}/icon/png/nextcloud-contacts.png";
    };
    sso = {
      id = 87;
      app = "authelia";
      name = "sso";
      hostname = infra.sso.name;
      site = infra.site.name;
      domain = infra.domain.user;
      fqdn = "${infra.sso.hostname}.${infra.sso.domain}";
      ip = "${infra.net.user}.${toString infra.sso.id}";
      localbind.port.http = infra.localhost.port.offset + infra.sso.id;
      oidc = {
        auth = {
          basic = "client_secret_basic"; # paperless, openweb-ui, miniflux
          post = "client_secret_post"; # nextcloud
        };
        grant = "authorization_code";
        policy = "two_factor";
        method = "S256";
        response.code = "code";
        scope = "openid profile groups email";
        scopes = ["openid" "profile" "groups" "email"];
        discoveryUri = "${infra.sso.url}/.well-known/openid-configuration";
        consent = "implicit";
      };
      url = "https://${infra.sso.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.sso.app}.png";
    };
    srv = {
      id = 100;
      app = "nixos";
      name = "srv";
      hostname = infra.srv.name;
      sshd = false;
      admin = {
        domain = infra.domain.admin;
        fqdn = "${infra.srv.hostname}.${infra.srv.admin.domain}";
        ip = "${infra.net.admin}.${toString infra.srv.id}";
      };
      user = {
        domain = infra.domain.user;
        fqdn = "${infra.srv.hostname}.${infra.srv.user.domain}";
        ip = "${infra.net.user}.${toString infra.srv.id}";
      };
      remote = {
        domain = infra.domain.remote;
        fqdn = "${infra.srv.hostname}.${infra.srv.remote.domain}";
        ip = "192.168.80.100";
      };
      virtual = {
        domain = infra.domain.virtual;
        fqdn = "${infra.srv.hostname}.${infra.srv.virtual.domain}";
        ip = "${infra.net.user}.${toString infra.srv.id}";
      };
    };
    srv2 = {
      id = 102;
      app = "nixos";
      name = "srv2";
      hostname = infra.srv2.name;
      sshd = true;
      admin = {
        domain = infra.domain.admin;
        fqdn = "${infra.srv2.hostname}.${infra.srv2.admin.domain}";
        ip = "${infra.net.admin}.${toString infra.srv2.id}";
      };
      user = {
        domain = infra.domain.user;
        fqdn = "${infra.srv2.hostname}.${infra.srv2.user.domain}";
        ip = "${infra.net.user}.${toString infra.srv2.id}";
      };
      remote = {
        domain = infra.domain.remote;
        fqdn = "${infra.srv2.hostname}.${infra.srv2.remote.domain}";
        ip = "192.168.80.102";
      };
      virtual = {
        domain = infra.domain.virtual;
        fqdn = "${infra.srv2.hostname}.${infra.srv.virtual.domain}";
        ip = "${infra.net.user}.${toString infra.srv2.id}";
      };
    };
    syslog = {
      id = infra.srv.id;
      app = "syslog-ng";
      name = "syslog";
      hostname = infra.syslog.name;
      admin = {
        domain = infra.domain.admin;
        fqdn = "${infra.syslog.hostname}.${infra.syslog.admin.domain}";
        ip = "${infra.net.admin}.${toString infra.syslog.id}";
      };
      user = {
        domain = infra.domain.user;
        fqdn = "${infra.syslog.hostname}.${infra.syslog.user.domain}";
        ip = "${infra.net.user}.${toString infra.syslog.id}";
      };
      remote = {
        domain = infra.domain.remote;
        fqdn = "${infra.syslog.hostname}.${infra.syslog.remote.domain}";
        ip = "192.168.80.100";
      };
      virtual = {
        domain = infra.domain.virtual;
        fqdn = "${infra.syslog.hostname}.${infra.syslog.virtual.domain}";
        ip = "${infra.net.virtual}.${toString infra.syslog.id}";
      };
    };
    pki = {
      id = 108;
      name = "pki";
      hostname = infra.pki.name;
      domain = infra.domain.admin;
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      ip = "${infra.net.admin}.${toString infra.pki.id}";
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
    ai = {
      id = 109;
      app = "open-webui";
      name = "ai";
      hostname = infra.ai.name;
      domain = infra.domain.user;
      fqdn = "${infra.ai.hostname}.${infra.ai.domain}";
      ip = "${infra.net.user}.${toString infra.ai.id}";
      worker.one = "http://127.0.0.1:11434";
      worker.two = "http://aiworker01.${infra.domain.user}:11434";
      localbind = {
        proto = infra.localhost.proto;
        port.http = infra.localhost.port.offset + infra.ai.id;
      };
      url = "https://${infra.ai.fqdn}";
      logo = "${infra.res.url}/icon/png/ollama.png";
    };
    status = {
      id = 110;
      app = "status";
      name = "status";
      hostname = infra.status.name;
      domain = infra.domain.user;
      fqdn = "${infra.status.hostname}.${infra.status.domain}";
      ip = "${infra.net.user}.${toString infra.status.id}";
      localbind.port.http = infra.localhost.port.offset + infra.status.id;
      url = "https://${infra.status.fqdn}";
      logo = "${infra.res.url}/icon/png/healthchecks.png";
    };
    kuma = {
      id = 111;
      app = "uptimekuma";
      name = "kuma";
      hostname = infra.kuma.name;
      domain = infra.domain.user;
      fqdn = "${infra.kuma.hostname}.${infra.kuma.domain}";
      ip = "${infra.net.user}.${toString infra.kuma.id}";
      localbind.port.http = infra.localhost.port.offset + infra.kuma.id;
      url = "https://${infra.kuma.fqdn}";
      logo = "${infra.res.url}/icon/png/healthchecks.png";
    };
    wiki = {
      id = 112;
      app = "mediawiki";
      name = "wiki";
      hostname = infra.wiki.name;
      domain = infra.domain.user;
      fqdn = "${infra.wiki.hostname}.${infra.wiki.domain}";
      ip = "${infra.net.user}.${toString infra.wiki.id}";
      localbind.port.http = infra.localhost.port.offset + infra.wiki.id;
      url = "https://${infra.wiki.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.wiki.app}.png";
    };
    nextcloud = {
      id = 117;
      app = "nextcloud";
      name = "nextcloud";
      hostname = infra.nextcloud.name;
      domain = infra.domain.user;
      fqdn = "${infra.nextcloud.hostname}.${infra.nextcloud.domain}";
      ip = "${infra.net.user}.${toString infra.nextcloud.id}";
      port = infra.port.webapps;
      localbind.port.http = infra.localhost.port.offset + infra.nextcloud.id;
      url = "https://${infra.nextcloud.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.nextcloud.name}-blue.png";
    };
    search = {
      id = 119;
      app = "searxng";
      name = "search";
      hostname = infra.search.name;
      domain = infra.domain.user;
      fqdn = "${infra.search.hostname}.${infra.search.domain}";
      ip = "${infra.net.user}.${toString infra.search.id}";
      port = infra.port.webapps;
      localbind.port.http = infra.localhost.port.offset + infra.search.id;
      query.url = "${infra.search.url}/search?q=<query>";
      urls = {
        search = "${infra.search.url}/search?q={searchTerms}";
        suggest = "${infra.search.url}/autocompleter?q={searchTerms}";
      };
      url = "https://${infra.search.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.search.app}.png";
    };
    paperless = {
      id = 125;
      app = "paperless";
      name = infra.paperless.app;
      hostname = infra.paperless.name;
      domain = infra.domain.user;
      fqdn = "${infra.paperless.hostname}.${infra.paperless.domain}";
      ip = "${infra.net.user}.${toString infra.paperless.id}";
      localbind.port.http = infra.localhost.port.offset + infra.paperless.id;
      url = "https://${infra.paperless.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.paperless.name}.png";
    };
    matrix = {
      id = 127;
      app = "tuwunnel";
      name = "matrix";
      ldap = false;
      self-register = {
        enable = true;
        password = "start";
      };
      externalHostname = "matrix.${infra.site.external.domain}";
      hostname = infra.matrix.name;
      domain = infra.domain.user;
      fqdn = "${infra.matrix.hostname}.${infra.matrix.domain}";
      ip = "${infra.net.user}.${toString infra.matrix.id}";
      access.cidr = "${infra.cidr.user}";
      localbind.port.http = infra.localhost.port.offset + infra.matrix.id;
      url = "https://${infra.matrix.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.matrix.app}.png";
    };
    vault = {
      id = 128;
      app = "vaultwarden";
      name = "vault";
      hostname = infra.vault.name;
      domain = infra.domain.user;
      fqdn = "${infra.vault.hostname}.${infra.vault.domain}";
      ip = "${infra.net.user}.${toString infra.vault.id}";
      localbind.port.http = infra.localhost.port.offset + infra.vault.id;
      url = "https://${infra.vault.fqdn}";
      logo = "${infra.res.url}/icon/png/bitwarden.png";
    };
    webarchiv = {
      id = 130;
      app = "readeck";
      name = "webarchiv";
      hostname = infra.webarchiv.name;
      domain = infra.domain.user;
      fqdn = "${infra.webarchiv.hostname}.${infra.webarchiv.domain}";
      ip = "${infra.net.user}.${toString infra.webarchiv.id}";
      localbind.port.http = infra.localhost.port.offset + infra.webarchiv.id;
      url = "https://${infra.webarchiv.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.webarchiv.app}.png";
    };
    portal = {
      id = 135;
      app = "homer";
      name = "start";
      hostname = infra.portal.name;
      domain = infra.domain.user;
      fqdn = "${infra.portal.hostname}.${infra.portal.domain}";
      ip = "${infra.net.user}.${toString infra.portal.id}";
      localbind.port.http = infra.localhost.port.offset + infra.portal.id;
      url = "https://${infra.portal.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.portal.app}.png";
    };
    res = {
      id = 141;
      app = "caddy";
      name = "res";
      hostname = infra.res.name;
      domain = infra.domain.user;
      fqdn = "${infra.res.hostname}.${infra.res.domain}";
      ip = "${infra.net.user}.${toString infra.res.id}";
      www.root = "/var/lib/caddy/res";
      url = "https://${infra.res.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.res.app}.png";
    };
    imap = {
      id = 143;
      hostname = "imap";
      admin = {
        domain = infra.domain.user;
        fqdn = "${infra.imap.hostname}.${infra.imap.admin.domain}";
        ip = "${infra.net.user}.${toString infra.imap.id}";
      };
      user = {
        domain = infra.domain.user;
        fqdn = "${infra.imap.hostname}.${infra.imap.user.domain}";
        ip = "${infra.net.user}.${toString infra.imap.id}";
      };
    };
    webacme = {
      id = 151;
      app = "cert-warden";
      name = "webacme";
      hostname = infra.webacme.name;
      domain = infra.domain.admin;
      fqdn = "${infra.webacme.hostname}.${infra.webacme.domain}";
      ip = "${infra.net.admin}.${toString infra.webacme.id}";
      localbind.port.http = infra.localhost.port.offset + infra.webacme.id;
      url = "https://${infra.webacme.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.webacme.app}.png";
    };
    webpki = {
      id = 152;
      app = "mkcert-web";
      name = "webpki";
      hostname = infra.webpki.name;
      domain = infra.domain.admin;
      fqdn = "${infra.webpki.hostname}.${infra.webpki.domain}";
      ip = "${infra.net.admin}.${toString infra.webpki.id}";
      localbind.port.http = infra.localhost.port.offset + infra.webpki.id;
      url = "https://${infra.webpki.fqdn}";
      logo = "${infra.res.url}/icon/png/cert-manager.png";
    };
    webmtls = {
      id = 153;
      app = "vaultls";
      name = "webmtls";
      hostname = infra.webmtls.name;
      domain = infra.domain.admin;
      fqdn = "${infra.webmtls.hostname}.${infra.webmtls.domain}";
      ip = "${infra.net.admin}.${toString infra.webmtls.id}";
      localbind.port.http = infra.localhost.port.offset + infra.webmtls.id;
      url = "https://${infra.webmtls.fqdn}";
      logo = "${infra.res.url}/icon/png/vault.png";
    };
    translate-lama = {
      id = 154;
      app = "ollama";
      name = "translate-lama";
      hostname = infra.translate-lama.name;
      domain = infra.domain.user;
      fqdn = "${infra.translate-lama.hostname}.${infra.translate-lama.domain}";
      ip = "${infra.net.user}.${toString infra.translate-lama.id}";
      localbind.port.http = infra.localhost.port.offset + infra.translate-lama.id;
      logo = "${infra.res.url}/icon/png/${infra.translate-lama.app}.png";
    };
    test = {
      id = 155;
      app = "test";
      name = "test";
      hostname = infra.test.name;
      domain = infra.domain.user;
      fqdn = "${infra.test.hostname}.${infra.test.domain}";
      ip = "${infra.net.user}.${toString infra.test.id}";
      url = "https://${infra.test.fqdn}";
      logo = "${infra.res.url}/icon/png/caddy.png";
    };
    grist = {
      id = 156;
      app = "grist";
      name = infra.grist.app;
      hostname = infra.grist.name;
      domain = infra.domain.user;
      fqdn = "${infra.grist.hostname}.${infra.grist.domain}";
      ip = "${infra.net.user}.${toString infra.grist.id}";
      localbind.port.http = infra.localhost.port.offset + infra.grist.id;
      url = "https://${infra.grist.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.grist.app}.png";
    };
    meshtastic-web = {
      id = 157;
      app = "meshtastic";
      name = "${infra.meshtastic-web.app}-web";
      hostname = infra.meshtastic-web.name;
      domain = infra.domain.user;
      fqdn = "${infra.meshtastic-web.hostname}.${infra.meshtastic-web.domain}";
      ip = "${infra.net.user}.${toString infra.meshtastic-web.id}";
      localbind.port.http = infra.localhost.port.offset + infra.meshtastic-web.id;
      url = "https://${infra.meshtastic-web.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.meshtastic-web.app}.png";
    };
    glance = {
      id = 158;
      app = "glance";
      name = infra.glance.app;
      hostname = infra.glance.name;
      domain = infra.domain.user;
      fqdn = "${infra.glance.hostname}.${infra.glance.domain}";
      ip = "${infra.net.user}.${toString infra.glance.id}";
      localbind.port.http = infra.localhost.port.offset + infra.glance.id;
      url = "https://${infra.glance.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.glance.app}.png";
    };
    immich = {
      id = 159;
      app = "immich";
      name = infra.immich.app;
      hostname = infra.immich.name;
      domain = infra.domain.user;
      fqdn = "${infra.immich.hostname}.${infra.immich.domain}";
      ip = "${infra.net.user}.${toString infra.immich.id}";
      container.ip = "${infra.container.network}.${toString infra.immich.id}";
      localbind.port.http = infra.localhost.port.offset + infra.immich.id;
      url = "https://${infra.immich.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.immich.app}.png";
    };
    ente = {
      id = 160;
      app = "ente";
      name = infra.ente.app;
      hostname = infra.ente.name;
      domain = infra.domain.user;
      fqdn = "${infra.ente.hostname}.${infra.ente.domain}";
      ip = "${infra.net.user}.${toString infra.ente.id}";
      localbind.port.http = infra.localhost.port.offset + infra.ente.id;
      url = "https://${infra.ente.fqdn}";
      logo = "${infra.res.url}/icon/png/ente-photos.png";
    };
    miniflux = {
      id = 161;
      app = "miniflux";
      name = infra.miniflux.app;
      hostname = infra.miniflux.name;
      domain = infra.domain.user;
      fqdn = "${infra.miniflux.hostname}.${infra.miniflux.domain}";
      ip = "${infra.net.user}.${toString infra.miniflux.id}";
      localbind.port.http = infra.localhost.port.offset + infra.miniflux.id;
      url = "https://${infra.miniflux.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.miniflux.app}.png";
    };
    navidrome = {
      id = 162;
      app = "navidrome";
      name = infra.navidrome.app;
      hostname = infra.navidrome.name;
      domain = infra.domain.user;
      fqdn = "${infra.navidrome.hostname}.${infra.navidrome.domain}";
      ip = "${infra.net.user}.${toString infra.navidrome.id}";
      localbind.port.http = infra.localhost.port.offset + infra.navidrome.id;
      url = "https://${infra.navidrome.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.navidrome.app}.png";
    };
    chef = {
      id = 163;
      app = "chef";
      name = infra.chef.app;
      hostname = infra.chef.name;
      domain = infra.domain.user;
      fqdn = "${infra.chef.hostname}.${infra.chef.domain}";
      ip = "${infra.net.user}.${toString infra.chef.id}";
      localbind.port.http = infra.localhost.port.offset + infra.chef.id;
      url = "https://${infra.chef.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.chef.app}.png";
    };
    onlyoffice = {
      id = 164;
      app = "onlyoffice";
      name = infra.onlyoffice.app;
      hostname = infra.onlyoffice.name;
      domain = infra.domain.user;
      fqdn = "${infra.onlyoffice.hostname}.${infra.onlyoffice.domain}";
      ip = "${infra.net.user}.${toString infra.onlyoffice.id}";
      localbind.port.http = infra.localhost.port.offset + infra.onlyoffice.id;
      url = "https://${infra.onlyoffice.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.onlyoffice.app}.png";
    };
    ollama01 = {
      id = 165;
      app = "ollama01";
      name = infra.ollama01.app;
      hostname = infra.ollama01.name;
      domain = infra.domain.admin;
      fqdn = "${infra.ollama01.hostname}.${infra.ollama01.domain}";
      ip = "${infra.net.user}.${toString infra.ollama01.id}";
      localbind.port.http = infra.localhost.port.offset + infra.ollama01.id;
    };
    rackula = {
      id = 170;
      app = "rackula";
      name = infra.rackula.app;
      hostname = infra.rackula.name;
      domain = infra.domain.admin;
      fqdn = "${infra.rackula.hostname}.${infra.rackula.domain}";
      ip = "${infra.net.user}.${toString infra.rackula.id}";
      localbind.port.http = infra.localhost.port.offset + infra.rackula.id;
      url = "https://${infra.rackula.fqdn}";
      logo = "${infra.res.url}/icon/png/mcmyadmin.png";
    };
    bentopdf = {
      id = 171;
      app = "bentopdf";
      name = infra.bentopdf.app;
      hostname = infra.bentopdf.name;
      domain = infra.domain.user;
      fqdn = "${infra.bentopdf.hostname}.${infra.bentopdf.domain}";
      ip = "${infra.net.user}.${toString infra.bentopdf.id}";
      localbind.port.http = infra.localhost.port.offset + infra.bentopdf.id;
      url = "https://${infra.bentopdf.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.bentopdf.app}.png";
    };
    web-check = {
      id = 172;
      app = "web-check";
      name = infra.web-check.app;
      hostname = infra.web-check.name;
      domain = infra.domain.user;
      fqdn = "${infra.web-check.hostname}.${infra.web-check.domain}";
      ip = "${infra.net.user}.${toString infra.web-check.id}";
      localbind.port.http = infra.localhost.port.offset + infra.web-check.id;
      url = "https://${infra.web-check.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.web-check.app}.png";
    };
    databasement = {
      id = 173;
      app = "databasement";
      name = infra.databasement.app;
      hostname = infra.databasement.name;
      domain = infra.domain.admin;
      fqdn = "${infra.databasement.hostname}.${infra.databasement.domain}";
      ip = "${infra.net.admin}.${toString infra.databasement.id}";
      localbind.port.http = infra.localhost.port.offset + infra.databasement.id;
      url = "https://${infra.databasement.fqdn}";
      logo = "${infra.res.url}/icon/png/webdb.png";
    };
    jellyfin = {
      id = 174;
      app = "jellyfin";
      name = infra.jellyfin.app;
      hostname = infra.jellyfin.name;
      domain = infra.domain.user;
      fqdn = "${infra.jellyfin.hostname}.${infra.jellyfin.domain}";
      ip = "${infra.net.user}.${toString infra.jellyfin.id}";
      localbind.port.http = infra.localhost.port.offset + infra.jellyfin.id;
      url = "https://${infra.jellyfin.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.jellyfin.app}.png";
    };
    kimai = {
      id = 175;
      app = "kimai";
      name = infra.kimai.app;
      hostname = infra.kimai.name;
      domain = infra.domain.user;
      fqdn = "${infra.kimai.hostname}.${infra.kimai.domain}";
      ip = "${infra.net.user}.${toString infra.kimai.id}";
      localbind.port.http = infra.localhost.port.offset + infra.kimai.id;
      url = "https://${infra.kimai.fqdn}";
      logo = "${infra.res.url}/icon/png/nextcloud-timemanager.png";
    };
    erpnext = {
      id = 176;
      app = "erpnext";
      name = infra.erpnext.app;
      hostname = infra.erpnext.name;
      domain = infra.domain.user;
      fqdn = "${infra.erpnext.hostname}.${infra.erpnext.domain}";
      ip = "${infra.net.user}.${toString infra.erpnext.id}";
      localbind.port.http = infra.localhost.port.offset + infra.erpnext.id;
      url = "https://${infra.erpnext.fqdn}";
      logo = "${infra.res.url}/icon/png/espocrm.png";
    };
    networking-toolbox = {
      id = 176;
      app = "networking-toolbox";
      name = infra.networking-toolbox.app;
      hostname = infra.networking-toolbox.name;
      domain = infra.domain.user;
      fqdn = "${infra.networking-toolbox.hostname}.${infra.networking-toolbox.domain}";
      ip = "${infra.net.user}.${toString infra.networking-toolbox.id}";
      localbind.port.http = infra.localhost.port.offset + infra.networking-toolbox.id;
      url = "https://${infra.networking-toolbox.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.networking-toolbox.app}.png";
    };
    wiki-go = {
      id = 177;
      app = "wiki-go";
      name = infra.wiki-go.app;
      hostname = infra.wiki-go.name;
      domain = infra.domain.user;
      fqdn = "${infra.wiki-go.hostname}.${infra.wiki-go.domain}";
      ip = "${infra.net.user}.${toString infra.wiki-go.id}";
      localbind.port.http = infra.localhost.port.offset + infra.wiki-go.id;
      url = "https://${infra.wiki-go.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.wiki-go.name}.png";
    };
    coturn = {
      id = 178;
      app = "coturn";
      name = infra.coturn.app;
      hostname = infra.coturn.name;
      domain = infra.domain.user;
      fqdn = "${infra.coturn.hostname}.${infra.coturn.domain}";
      ip = "${infra.net.user}.${toString infra.coturn.id}";
      localbind.port.http = infra.localhost.port.offset + infra.coturn.id;
      url = "https://${infra.coturn.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.coturn.name}.png";
    };
    websurfx = {
      id = 179;
      app = "websurfx";
      name = infra.websurfx.app;
      hostname = infra.websurfx.name;
      domain = infra.domain.user;
      fqdn = "${infra.websurfx.hostname}.${infra.websurfx.domain}";
      ip = "${infra.net.user}.${toString infra.websurfx.id}";
      localbind.port.http = infra.localhost.port.offset + infra.websurfx.id;
      url = "https://${infra.websurfx.fqdn}";
      logo = "${infra.res.url}/icon/png/searxng.png";
    };
    timetrack = {
      id = 180;
      app = "timetrack";
      name = infra.timetrack.app;
      hostname = infra.timetrack.name;
      domain = infra.domain.user;
      fqdn = "${infra.timetrack.hostname}.${infra.timetrack.domain}";
      ip = "${infra.net.user}.${toString infra.timetrack.id}";
      localbind.port.http = infra.localhost.port.offset + infra.timetrack.id;
      url = "https://${infra.timetrack.fqdn}";
      logo = "${infra.res.url}/icon/png/nextcloud-timemanager.png";
    };
    donetick = {
      id = 181;
      app = "donetick";
      name = infra.donetick.app;
      hostname = infra.donetick.name;
      domain = infra.domain.user;
      fqdn = "${infra.donetick.hostname}.${infra.donetick.domain}";
      ip = "${infra.net.user}.${toString infra.donetick.id}";
      localbind.port.http = infra.localhost.port.offset + infra.donetick.id;
      url = "https://${infra.donetick.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.donetick.app}.png";
    };
    zipline = {
      id = 182;
      app = "zipline";
      name = infra.zipline.app;
      hostname = infra.zipline.name;
      domain = infra.domain.user;
      fqdn = "${infra.zipline.hostname}.${infra.zipline.domain}";
      ip = "${infra.net.user}.${toString infra.zipline.id}";
      localbind.port.http = infra.localhost.port.offset + infra.zipline.id;
      url = "https://${infra.zipline.fqdn}";
      logo = "${infra.res.url}/icon/png/${infra.zipline.app}.png";
    };
    dumbdrop = {
      id = 183;
      app = "dumbdrop";
      name = infra.dumbdrop.app;
      hostname = infra.dumbdrop.name;
      domain = infra.domain.user;
      fqdn = "${infra.dumbdrop.hostname}.${infra.dumbdrop.domain}";
      ip = "${infra.net.user}.${toString infra.dumbdrop.id}";
      localbind.port.http = infra.localhost.port.offset + infra.dumbdrop.id;
      url = "https://${infra.dumbdrop.fqdn}";
      logo = "${infra.res.url}/icon/png/dropbox.png";
    };
  };
in {infra = infra;}
