# kimai
# sudo bash
# cd /nix/store/<hash>-kimai-<yoursite>-2.40.0/bin/
# sudo -u kimai ./console  kimai:user:create -- admin admin@adm.corp ROLE_SUPER_ADMIN
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.kimai.ip} ${infra.kimai.hostname} ${infra.kimai.fqdn}";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."user".addresses = [{Address = "${infra.kimai.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.kimai.fqdn}" = {
      listenAddresses = [infra.kimai.ip];
      extraConfig = ''import intraproxy ${toString infra.kimai.localbind.port.http}'';
    };
    nginx.virtualHosts."${infra.site.name}".listen = [
      {
        addr = infra.localhost.ip;
        port = infra.kimai.localbind.port.http;
      }
    ];
    kimai.sites."${infra.site.name}" = {
      database.createLocally = true;
      settings = {
        kimai = {
          ldap = {
            activate = true;
            connection = {
              host = infra.ldap.uriHost;
              port = infra.port.ldap;
              useSsl = false;
              useStartTls = false;
              # username = infra.ldap.bind.user;
              # password = infra.ldap.bind.password;
            };
            user = {
              baseDn = infra.ldap.baseDN;
              usernameAttribute = "uid";
              # filter = "(&(objectClass=inetOrgPerson))";
              # attributesFilter: (objectClass=Person);
              # attributes = [
              #   { ldap_attr: "usernameAttribute", user_method: setUserIdentifier }
              #   { ldap_attr: "usernameAttribute", user_method: setEmail }
              #   { ldap_attr: cn, user_method: setAlias }
              # ];
            };
            # role = {
            #   baseDn = "ou=groups,$(infra.ldap.base)";
            #   filter = "(&(objectClass=groupOfNames))";
            #   usernameAttribute = "uid";
            #   nameAttribute = "cn";
            #   userDnAttribute = "member";
            #   groups = [
            #     { ldap_value: group1, role: ROLE_TEAMLEAD }
            #     { ldap_value: kimai_admin, role: ROLE_ADMIN }
            #  ];
          };
        };
      };
    };
  };
}
