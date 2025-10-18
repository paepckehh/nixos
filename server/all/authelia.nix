{config, ...}: let
  infra = {
    admin = "admin";
    contact = {
      name = "IT SERVICE";
      email = "it@${infra.smtp.maildomain}";
    };
    localhost = {
      ip = "127.0.0.1";
      port.offset = 7000;
    };
    id = {
      admin = 0;
      user = 6;
    };
    port = {
      smtp = 25;
      http = 80;
      https = 443;
      webapp = [infra.port.http infra.port.https];
    };
    domain = {
      tld = "corp";
      admin = "adm.${infra.domain.tld}";
      user = "dbt.${infra.domain.tld}";
    };
    cidr = {
      admin = "${infra.net.admin}.0/24";
      user = "${infra.net.user}.0/23";
    };
    net = {
      prefix = "10.20";
      admin = "${infra.net.prefix}.${toString infra.id.admin}";
      user = "${infra.net.prefix}.${toString infra.id.user}";
    };
    namespace = {
      admin = "${toString infra.id.admin}";
      user = "${toString infra.id.user}";
    };
    pki = {
      acmeContact = "acme@${infra.pki.fqdn}";
      caFile = "/etc/ca.crt";
      hostname = "pki";
      domain = infra.domain.admin;
      maildomain = "debitor.de";
      fqdn = "${infra.pki.hostname}.${infra.pki.domain}";
      url = "https://${infra.pki.fqdn}/acme/acme/directory";
    };
    smtp = {
      hostname = "smtp";
      domain = infra.domain.admin;
      fqdn = "${infra.smtp.hostname}.${infra.smtp.domain}";
      maildomain = "debitor.de";
      port = 25;
    };
    ldap = {
      backend = "lldap";
      uri = "ldap://10.20.0.126:3890";
      basedn = "DC=dbt,DC=corp";
      bind = {
        dn = "UID=bind,OU=people,${infra.ldap.basedn}";
        pwd = "startbind";
      };
    };
    sso = {
      id = 142;
      name = "sso";
      site = "debicloud";
      hostname = infra.sso.name;
      domain = infra.domain.user;
      fqdn = "${infra.sso.hostname}.${infra.sso.domain}";
      ip = "${infra.net.user}.${toString infra.sso.id}";
      network = infra.cidr.user;
      namespace = infra.namespace.user;
      localbind = {
        ip = infra.localhost.ip;
        port.http = infra.localhost.port.offset + infra.sso.id;
      };
    };
  };
in {
  #############
  #-=# AGE #=-#
  #############
  age = {
    secrets = {
      "authelia-jwt-${infra.sso.site}" = {
        file = ../../modules/resources/authelia-jwt.age;
        owner = "authelia-${infra.sso.site}";
        group = "authelia-${infra.sso.site}";
      };
      "authelia-key-${infra.sso.site}" = {
        file = ../../modules/resources/authelia-key.age;
        owner = "authelia-${infra.sso.site}";
        group = "authelia-${infra.sso.site}";
      };
      "authelia-session-${infra.sso.site}" = {
        file = ../../modules/resources/authelia-session.age;
        owner = "authelia-${infra.sso.site}";
        group = "authelia-${infra.sso.site}";
      };
    };
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    groups."authelia-${infra.sso.site}" = {};
    users = {
      "authelia-${infra.sso.site}" = {
        group = "authelia-${infra.sso.site}";
        isSystemUser = true;
        hashedPassword = null; # disable ldap service account interactive logon
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAA-#locked#-"]; # lock-down ssh ssoentication
      };
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks.${infra.sso.namespace}.addresses = [
    {Address = "${infra.sso.ip}/32";}
  ];

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    extraHosts = "${infra.sso.ip} ${infra.sso.hostname} ${infra.sso.fqdn}";
    firewall.allowedTCPPorts = infra.port.webapp;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    authelia.instances = {
      "${infra.sso.site}" = {
        enable = true;
        secrets = {
          jwtSecretFile = config.age.secrets."authelia-jwt-${infra.sso.site}".path;
          storageEncryptionKeyFile = config.age.secrets."authelia-key-${infra.sso.site}".path;
          sessionSecretFile = config.age.secrets."authelia-session-${infra.sso.site}".path;
        };
        settings = {
          # server.address = "tcp4://${infra.sso.localbind.ip}:${toString infra.sso.localbind.port.http}";
          server.address = "tcp4://10.20.6.142:7142";
          theme = "dark";
          log = {
            level = "debug";
            format = "text";
          };
          authentication_backend = {
            refresh_interval = "1m";
            password_reset.disable = true;
            password_change.disable = true;
            ldap = {
              implementation = infra.ldap.backend;
              address = infra.ldap.uri;
              tls.skip_verify = true;
              base_dn = infra.ldap.basedn;
              user = infra.ldap.bind.dn;
              password = infra.ldap.bind.pwd;
            };
          };
          access_control = {
            default_policy = "deny";
            rules = [
              {
                domain = ["sso.dbt.corp"];
                policy = "bypass";
              }
              {
                domain = ["*.dbt.corp"];
                policy = "one_factor";
              }
            ];
          };
          session = {
            domain = "dbt.corp";
            same_site = "lax";
            inactivity = "3h";
            expiration = "12h";
            remember_me = "32d";
            redis.host = "/run/redis-authelia-${infra.sso.site}/redis.sock";
          };
          regulation = {
            max_retries = 5;
            find_time = "5m";
            ban_time = "15m";
          };
          storage = {
            local.path = "/var/lib/authelia-${infra.sso.site}/db.sqlite3";
          };
          notifier = {
            disable_startup_check = false;
            filesystem.filename = "/var/lib/authelia-${infra.sso.site}/notification.txt";
          };
          telemetry = {
            metrics = {
              enabled = true;
              address = "tcp://localhost:9102/metrics";
            };
          };
          webauthn = {
            disable = false;
            enable_passkey_login = true;
            display_name = "Authelia";
            attestation_conveyance_preference = "none";
            timeout = "120 seconds";
            metadata.enabled = false;
            selection_criteria = {
              attachment = "cross-platform";
              discoverability = "preferred";
              user_verification = "preferred";
            };
          };
        };
      };
    };
    redis.servers."authelia-${infra.sso.site}" = {
      enable = true;
      group = "authelia-${infra.sso.site}";
      user = "authelia-${infra.sso.site}";
      port = 0;
      unixSocket = "/run/redis-authelia-${infra.sso.site}/redis.sock";
      unixSocketPerm = 600;
    };

    nginx.virtualHosts."auth.example.com" = {
      enableACME = true;
      forceSSL = true;
      acmeRoot = null;
      locations."/" = {
        proxyPass = "http://${infra.sso.localbind.ip}:${toString infra.sso.localbind.port.http}";
        proxyWebsockets = true;
      };
    };
    caddy = {
      enable = false;
      virtualHosts."${infra.sso.fqdn}".extraConfig = ''
        bind ${infra.sso.ip}
        reverse_proxy ${infra.sso.localbind.ip}:${toString infra.sso.localbind.port.http}
        tls ${infra.pki.acmeContact} {
              ca ${infra.pki.url}
              ca_root ${infra.pki.caFile}
        }
        @not_intranet {
          not remote_ip ${infra.sso.network}
        }
        respond @not_intranet 403
        log {
          output file ${config.services.caddy.logDir}/${infra.sso.name}.log
                }'';
    };
  };
}
