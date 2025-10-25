{
  site = {
    id = 20;
    name = "home";
    domain = {
      tld = "corp";
      # scope => home.corp
      external = "paepcke.de";
    };
    networkrange = {
      oct1 = 10; # prefix
      oct2 = infra.site.id;
      # scope => 10.20.0.0/16
    };
  };
  admin = {
    uid = "admin";
    displayName = "IT TEAM @ ${infra.site.name}";
    email = "it@${infra.smtp.maildomain}";
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
    prefix = "${toString infra.site.networkrange.oct1}.${toString infra.site.networkrange.oct2}";
    admin = "${infra.net.prefix}.${toString infra.id.admin}";
    user = "${infra.net.prefix}.${toString infra.id.user}";
    remote = "${infra.net.prefix}.${toString infra.id.remote}";
  };
  cidr = {
    admin = "${infra.net.user}.0/23"; # 10.20.0.0/23
    user = "${infra.net.user}.0/23"; # 10.20.6.0/23
    remote = "${infra.net.remote}.0/23"; # 10.20.66.0/23
    clients = [infra.cidr.user infra.cidr.remote];
    all = [infra.cidr.admin infra.cidr.user infra.cidr.remote];
  };
  domain = {
    domain = "${infra.site.name}.${infra.site.domain.tld}";
    admin = "admin.${infra.domain.domain}"; # admin.home.corp
    user = "user.${infra.domain.domain}"; # user.home.corp
    remote = "remote.${infra.domain.domain}"; # remote.home.corp
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
    domain = infra.domain.admin;
    fqdn = "${infra.smtp.hostname}.${infra.smtp.domain}";
    extern.domain = infra.domain.extern;
  };
  ldap = {
    id = 126;
    name = "ldap";
    ip = "${infra.admin.user}.${toString infra.ldap.id}";
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
    name = "iam";
    hostname = infra.iam.name;
    domain = infra.domain.user;
    fqdn = "${infra.iam.hostname}.${infra.iam.domain}";
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
    port = infra.ports.dns;
    ip = "${infra.net.user}.${toString infra.dns.id}";
    access = infra.cidr.all;
    namespace = infra.namespace.user;
  };
}
