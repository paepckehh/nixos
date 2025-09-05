{
  pkgs,
  lib,
  ...
}: let
  ldapDomain = "intra.lan";
  ldapSuffix = "dc=intra,dc=lan";

  ldapRootUser = "admin";
  ldapRootPassword = "start"; # agenix

  testUser = "myuser";
  testPassword = "start"; # agenix
in {
  environment.etc."oncall-secrets.yml".text = ''
    auth:
      ldap_bind_password: "${ldapRootPassword}"
  '';

  services.oncall = {
    enable = true;
    settings = {
      auth = {
        module = "oncall.auth.modules.ldap_import";
        ldap_url = "ldap://localhost";
        ldap_user_suffix = "";
        ldap_bind_user = "cn=root,${ldapSuffix}";
        ldap_base_dn = "ou=accounts,${ldapSuffix}";
        ldap_search_filter = "(uid=%s)";
        import_user = true;
        attrs = {
          username = "uid";
          full_name = "cn";
          email = "mail";
          call = "telephoneNumber";
          sms = "mobile";
        };
      };
    };
    secretFile = "/etc/oncall-secrets.yml";
  };

  services.openldap = {
    enable = true;
    settings = {
      children = {
        "cn=schema".includes = [
          "${pkgs.openldap}/etc/schema/core.ldif"
          "${pkgs.openldap}/etc/schema/cosine.ldif"
          "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
          "${pkgs.openldap}/etc/schema/nis.ldif"
        ];
        "olcDatabase={1}mdb" = {
          attrs = {
            objectClass = [
              "olcDatabaseConfig"
              "olcMdbConfig"
            ];
            olcDatabase = "{1}mdb";
            olcDbDirectory = "/var/lib/openldap/db";
            olcSuffix = ldapSuffix;
            olcRootDN = "cn=${ldapRootUser},${ldapSuffix}";
            olcRootPW = ldapRootPassword;
          };
        };
      };
    };
    declarativeContents = {
      ${ldapSuffix} = ''
        dn: ${ldapSuffix}
        objectClass: top
        objectClass: dcObject
        objectClass: organization
        o: ${ldapDomain}

        dn: ou=accounts,${ldapSuffix}
        objectClass: top
        objectClass: organizationalUnit

        dn: uid=${testUser},ou=accounts,${ldapSuffix}
        objectClass: top
        objectClass: inetOrgPerson
        uid: ${testUser}
        userPassword: ${testPassword}
        cn: Test User
        sn: User
        mail: test@example.org
        telephoneNumber: 012345678910
        mobile: 012345678910
      '';
    };
  };
}
