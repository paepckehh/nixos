# generic server base setup
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../siteconfig/config.nix).infra;
in {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../configuration.nix
    ../client/addrootCA.nix
    ../client/addrootCA-ext.nix
    ../client/addCache.nix
    ../client/addOpenSnitch-addSrv.nix
    # ../storage/backup.nix
  ];

  #######
  # AGE #
  #######
  age.identityPaths = ["/nix/persist/etc/ssh/ssh_host_ed25519_key"];

  ##############
  #-=# I18N #=-#
  ##############
  i18n.defaultLocale = lib.mkForce infra.locale.LC.server;

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    kernelModules = infra.kernel.whitelist.server;
    kernelParams = infra.kernel.params.server;
    supportedFilesystems = infra.kernel.fs.server;
    initrd.availableKernelModules = infra.kernel.whitelist.server;
  };

  ##############
  #-=# USER #=-#
  ##############
  users = {
    users = {
      me = {
        extraGroups = ["docker" "libvirtd"];
      };
      backup = {
        uid = infra.backup.uid;
        isNormalUser = true;
        isSystemUser = false;
        group = "backup";
        openssh.authorizedKeys.keys = [''command="${pkgs.rrsync}/bin/rrsync /mnt/tank/backup/",restrict ${infra.backup.sshKey}''];
      };
      samba = {
        uid = infra.samba.uid;
        isNormalUser = true;
        isSystemUser = false;
        group = "samba";
        openssh.authorizedKeys.keys = [''ssh-ed25519 ***locked**''];
      };
    };
    groups = {
      backup.gid = infra.backup.uid;
      samba.gid = infra.samba.uid;
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.sudo-rs.wheelNeedsPassword = lib.mkForce true;

  ##############
  # NETWORKING #
  ##############
  networking = {
    hostName = "srv-default-hostname";
    usePredictableInterfaceNames = lib.mkForce true;
    nameservers = [infra.dns.ip];
    networkmanager = {
      enable = true;
      unmanaged = ["enp" "enp*"];
    };
    firewall = {
      allowedUDPPorts = infra.port.webapps;
      allowedTCPPorts = (
        if (config.services.openssh.enable == true)
        then [infra.port.ssh infra.port.http infra.port.https]
        else infra.port.webapps
      );
    };
  };

  #############
  #-=# NIX #=-#
  #############
  nix = {
    gc = {
      automatic = false;
      dates = "03:00";
      persistent = false;
      randomizedDelaySec = "15min";
      options = "--delete-older-than 12d";
    };
    optimise = {
      automatic = false;
      dates = "04:00";
      persistent = false;
      randomizedDelaySec = "15min";
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers.backend = "docker";
    docker = {
      daemon.settings = {
        experimental = true;
        dns = [infra.dns.resolver.user.primary infra.dns.resolver.user.secondary];
        log-driver = "journald";
        storage-driver = "overlay2";
        default-address-pools = [
          {
            base = infra.cidr.container;
            size = infra.cidr.netmask;
          }
        ];
      };
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    cockpit = {
      enable = lib.mkDefault false;
      plugins = [
        pkgs.cockpit-files
        pkgs.cockpit-zfs
      ];
      port = infra.port.cockpit;
      settings = {
        WebService = {
          AllowUnencrypted = false;
          LoginTo = false;
        };
      };
    };
    caddy = {
      enable = lib.mkDefault false;
      logFormat = lib.mkForce "level INFO";
      globalConfig = ''
        acme_ca ${infra.pki.acme.url}
        acme_ca_root ${infra.pki.certs.rootCA.path}
        email ${infra.pki.acme.contact}
        grace_period 3s
        default_sni ${infra.portal.fqdn}
        fallback_sni ${infra.portal.fqdn}
        renew_interval 24h
      '';
      extraConfig = ''
        (admin) {
           tls {
              curves x25519
              protocols tls1.3 tls1.3
              client_auth {
                  mode require_and_verify
                  trust_pool file {
                     pem_file /etc/ca-mtls-admin.pem
                  }
              }
           }
           @not_adminnet { not remote_ip ${infra.cidr.admin} }
           respond @not_adminnet 403
        }
        (intra) {
           tls {
              curves x25519
              protocols tls1.3 tls1.3
              client_auth {
                  mode verify_if_given
                  trust_pool file {
                     pem_file /etc/ca-mtls-user.pem
                  }
              }
           }
           @not_intranet { not remote_ip ${infra.cidr.user} ${infra.cidr.container} }
           respond @not_intranet 403
        }
        (auth) {
          forward_auth ${infra.sso.url} {
             uri /api/authz/forward-auth
             copy_headers Remote-User Remote-Email
          }
        }
        (adminproxy) {
           import admin
           reverse_proxy ${infra.localhost.ip}:{args[0]} {
              transport http {
                 compression off
              }
           }
        }
        (intraproxy) {
           import intra
           reverse_proxy ${infra.localhost.ip}:{args[0]} {
              transport http {
                 compression off
              }
           }
        }
        (intraauthproxy) {
           import intra
           import auth
           reverse_proxy ${infra.localhost.ip}:{args[0]} {
              transport http {
                 compression off
              }
              header_up Remote-Groups user
           }
        }
        (admincontainer) {
           import admin
           reverse_proxy {args[0]}:${toString infra.port.http} {
              transport http {
                 compression off
              }
           }
        }
        (intracontainer) {
           import intra
           reverse_proxy {args[0]}:{args[1]} {
              transport http {
                 compression off
              }
           }
        }
      '';
    };
  };

  ###########
  # SYSTEMD #
  ###########
  systemd = {
    tmpfiles.rules = [
      "d /mnt/tank/backup 0770 backup backup"
      "d /mnt/tank/samba  0770 samba samba"
    ];
    services = {
      caddy = {
        after = ["sockets.target"];
        wants = ["sockets.target"];
        wantedBy = ["multi-user.target"];
      };
      nginx = {
        after = ["sockets.target"];
        wants = ["sockets.target"];
        wantedBy = ["multi-user.target"];
      };
    };
    network = {
      enable = true;
      netdevs = {
        "01-admin-vlan" = {
          vlanConfig.Id = infra.vlan.admin;
          netdevConfig = {
            Kind = "vlan";
            Name = "01-admin-vlan";
          };
        };
        "02-user-vlan" = {
          vlanConfig.Id = infra.vlan.user;
          netdevConfig = {
            Kind = "vlan";
            Name = "02-user-vlan";
          };
        };
        "80-br0" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "80-br0";
          };
        };
        "90-dummy0" = {
          netdevConfig = {
            Kind = "dummy";
            Name = "90-dummy0";
          };
        };
      };
      networks = {
        "55-link" = {
          enable = true;
          DHCP = "ipv4";
          matchConfig.Name = "enp1s0f0"; # t640
          networkConfig = {
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
        "56-link" = {
          enable = true;
          DHCP = "ipv4";
          matchConfig.Name = "enp1s0f4u2u1"; # usb
          networkConfig = {
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
        "${infra.namespace.admin}" = {
          enable = lib.mkDefault false;
          domains = [infra.domain.admin];
          matchConfig.Name = "01-admin-vlan";
          linkConfig.ActivationPolicy = "always-up";
          networkConfig = {
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
        "${infra.namespace.user}" = {
          enable = lib.mkDefault false;
          domains = [infra.domain.user];
          matchConfig.Name = "02-user-vlan";
          linkConfig.ActivationPolicy = "always-up";
          networkConfig = {
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
        "${infra.namespace.container}" = {
          enable = lib.mkDefault false;
          matchConfig.Name = "80-br0";
          address = ["${infra.container.bridge.ip}/${toString infra.cidr.netmask}"];
          vlan = ["01-admin-vlan" "02-user-vlan"];
          networkConfig = {
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
        "${infra.namespace.container}-dummy0" = {
          enable = lib.mkDefault false;
          matchConfig.Name = "90-dummy0";
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.net.container}.253/32";}];
          networkConfig = {
            Bridge = "80-br0";
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
      };
    };
  };
}
