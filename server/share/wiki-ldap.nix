{
  lib,
  pkgs,
  ...
}: let
  infra = {
    lan = {
      services = {
        wiki = {
          ip = "10.20.6.123";
          hostname = "wiki";
          domain = "dbt.corp";
          mail = "it@debitor.de";
          namespace = "06-dbt";
          network = "10.20.6.0/23";
          ports.tcp = 443;
          localbind = {
            ip = "127.0.0.1";
            ports.tcp = 7123;
          };
        };
      };
    };
  };
in {
  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.lan.services.wiki.namespace}.addresses = [{Address = "${infra.lan.services.wiki.ip}/32";}];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.lan.services.wiki.ip} ${infra.lan.services.wiki.hostname} ${infra.lan.services.wiki.hostname}.${infra.lan.services.wiki.domain}";
    firewall.allowedTCPPorts = [infra.lan.services.wiki.ports.tcp];
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    mediawiki = {
      enable = true;
      name = "MediaWiki";
      httpd.virtualHost = {
        # hostName = "${infra.lan.services.wiki.hostname}.${infra.lan.services.wiki.domain}";
        hostName = "localhost:7123";
        adminAddr = "${infra.lan.services.wiki.mail}";
        listen = [
          {
            ip = "${infra.lan.services.wiki.localbind.ip}";
            port = infra.lan.services.wiki.localbind.ports.tcp;
            ssl = false;
          }
        ];
      };
      passwordFile = pkgs.writeText "password" "cardbotnine";
      extraConfig = ''
        # Disable anonymous editing
        $wgGroupPermissions['*']['edit'] = false;
        # Make VisualEditor default
        $wgDefaultUserOptions['visualeditor-editor'] = "visualeditor";
        $wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;
        $wgAuth = new LdapAuthenticationPlugin();
        # LDAP Debug
        #$wgLDAPDebug = 10;
        #$wgDebugLogGroups["ldap"] = "/tmp/ldap.log" ;
        # LDAP
        $wgLDAPDomainNames = array('dbt.corp' );
        $wgLDAPServerNames = array('dbt.corp' => '10.20.0.126:3890' );
        $wgLDAPEncryptionType = array('dbt.corp' => 'ssl' );
        $wgLDAPUseSSL = array('dbt.corp' => false );
        $wgLDAPBaseDNs = array('dbt.corp' => 'dc=dbt,dc=corp' );
        $wgLDAPSearchAttributes = array('dbt.corp' => 'uid' );
        $wgLDAPUseLocal = true;
        $wgMinimalPasswordLength = 8;
        $wgLDAPProxyAgent = array("dbt.corp" => "UID=bind,CN=persons,DC=dbt,DC=corp" );
        $wgLDAPProxyAgentPassword = array("dbt.corp" => "startstart" );
        $wgLDAPUpdateLDAP = array("dbt.corp" => false );
        $wgLDAPAddLDAPUsers = array("dbt.corp" => false );
        #$wgLDAPRetrievePrefs = array("dbt.corp" => true );
        #$wgLDAPPPreferences = array("dbt.corp" => true );
        #$wgLDAPGroupUseFullDN = array("dbt.corp" => true );
        #$wgLDAPGroupObjectclass = array( "dbt.corp" => "group" );
        #$wgLDAPGroupAttribute = array( "dbt.corp" => "member" );
        #$wgLDAPGroupMemberOfAttribute = array( "dbt.corp" => "memberof" );
        #$wgLDAPGroupSearchNestedGroups = array( "dbt.corp" => true );
        #$wgLDAPGroupNameAttribute = array( "dbt.corp" => "cn" );
        #$wgLDAPUseLDAPGroups = array( "dbt.corp" => true );
        #$wgLDAPGroupsUseMemberOf = array( "dbt.corp" => true );
      '';
      extensions = {
        # null -> enable extention (default bundled only)
        VisualEditor = null;
      };
    };
    caddy = {
      enable = false;
      logDir = lib.mkForce "/var/log/caddy";
      logFormat = lib.mkForce "level INFO";
      virtualHosts."${infra.lan.services.wiki.hostname}.${infra.lan.services.wiki.domain}".extraConfig = ''
        bind ${infra.lan.services.wiki.ip}
        reverse_proxy ${infra.lan.services.wiki.localbind.ip}:${toString infra.lan.services.wiki.localbind.ports.tcp}
        tls pki@adm.corp {
              ca_root /etc/ca.crt
              ca https://pki.adm.corp/acme/acme/directory
        }
        @not_intranet {
          not remote_ip ${infra.lan.services.wiki.network}
        }
        respond @not_intranet 403
      '';
    };
  };
}
