{
  site = {
    id = 20;
    name = "home";
    domain = {
      tld = "corp"; # result => home.corp
      external = "paepcke.de";
    };
    networkrange = {
      oct1 = 10; # prefix
      oct2 = site.id; # result => 10.20.0.0/16
    };
  };
  admin = {
    uid = "admin";
    displayName = "IT TEAM @ ${site.name}";
    email = "it@${smtp.maildomain}";
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
  net = {
    prefix = "${toString site.networkrange.oct1}.${toString site.networkrange.oct2}";
    admin = "${net.prefix}.${toString id.admin}";
    user = "${net.prefix}.${toString id.user}";
    remote = "${net.prefix}.${toString id.remote}";
  };
  cidr = {
    netmask = 23; # result => /23 => 255.255.254.0 => 512 ip/net
    admin = "${net.user}.0/${toString cidr.netmask}"; # result => 10.20.0.0/23
    user = "${net.user}.0/${toString cidr.netmask}"; # result => 10.20.6.0/23
    remote = "${net.remote}.0/${toString cidr.netmask}"; # result => 10.20.66.0/23
    clients = [cidr.user cidr.remote];
    all = [cidr.admin cidr.user cidr.remote];
  };
  domain = {
    domain = "${site.name}.${site.domain.tld}";
    admin = "admin.${domain.domain}"; # result => admin.home.corp
    user = "user.${domain.domain}"; # result => user.home.corp
    remote = "remote.${domain.domain}"; # result => remote.home.corp
  };
  namespace = {
    prefix = "net";
    admin = "${namespace.prefix}-${toString id.admin}";
    user = "${namespace.prefix}-${toString id.user}";
    remote = "${namespace.prefix}-${toString id.remote}";
  };
  port = {
    dns = 53;
    smtp = 25;
    imap = 143;
    ldap = 3890;
    http = 80;
    https = 443;
    webapps = [port.http port.https];
  };
  pki = {
    acmeContact = admin.email;
    caFile = "/etc/ca.crt";
    hostname = "pki";
    domain = domain.user;
    fqdn = "${pki.hostname}.${pki.domain}";
    url = "https://${pki.fqdn}/acme/acme/directory";
  };
  smtp = {
    hostname = "smtp";
    domain = domain.admin;
    fqdn = "${smtp.hostname}.${smtp.domain}";
    extern.domain = domain.extern;
  };
  ldap = {
    id = 126;
    name = "ldap";
    ip = "${admin.user}.${toString ldap.id}";
    port = port.ldap;
    url = "http://${ldap.ip}:${toString ldap.port}";
    uri = "ldap://${ldap.ip}:${toString ldap.port}";
    base = "dc=${domain.domain},dc=${domain.tld}";
    bind = {
      dn = "cn=bind,ou=persons,${ldap.base}";
      pwd = "startbind";
    };
  };
  iam = {
    id = ldap.id;
    name = "iam";
    hostname = iam.name;
    domain = domain.user;
    fqdn = "${iam.hostname}.${iam.domain}";
    ip = "${net.user}.${toString iam.id}";
    ports = ports.webapps;
    localbind.port = localhost.port.offset + iam.id;
  };
  dns = {
    id = 53;
    name = "dns";
    hostname = dns.name;
    domain = domain.user;
    fqdn = "${dns.hostname}.${dns.domain}";
    port = ports.dns;
    ip = "${net.user}.${toString dns.id}";
    access = cidr.all;
    namespace = namespace.user;
  };
}
