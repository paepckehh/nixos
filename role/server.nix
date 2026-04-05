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

  #######
  # AGE #
  #######
  age.identityPaths = ["/nix/persist/etc/ssh/ssh_host_ed25519_key"];

  ##############
  #-=# BOOT #=-#
  ##############
  boot.enableContainers = true;

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [ragenix];

  ##############
  #-=# USER #=-#
  ##############
  users.users.me.extraGroups = ["podman" "docker" "libvirtd"];

  ##################
  #-=# SECURITY #=-#
  ##################
  security.sudo-rs.wheelNeedsPassword = lib.mkForce true;

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
    containers.enable = true;
    docker.enable = lib.mkDefault false;
    oci-containers.backend = "docker";
    docker = {
      daemon.settings = {
        experimental = true;
        dns = [infra.dns.ip];
        default-address-pools = [
          {
            base = infra.cidr.container;
            size = 23;
          }
        ];
      };
    };
  };

  ###########
  # SYSTEMD #
  ###########
  systemd = {
    services = {
      systemd-networkd = {
        environment.SYSTEMD_LOG_LEVEL = "info";
      };
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
        "br0" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "br0";
          };
        };
        "dummy0" = {
          netdevConfig = {
            Kind = "dummy";
            Name = "dummy0";
          };
        };
        "admin-vlan" = {
          vlanConfig.Id = infra.vlan.admin;
          netdevConfig = {
            Kind = "vlan";
            Name = "admin-vlan";
          };
        };
        "user-vlan" = {
          vlanConfig.Id = infra.vlan.user;
          netdevConfig = {
            Kind = "vlan";
            Name = "user-vlan";
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
        "${infra.namespace.bridge}" = {
          enable = true;
          bridgeConfig = {};
          vlan = ["admin-vlan" "user-vlan"];
          matchConfig.Name = "br0";
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.net.bridge}.1/${toString infra.cidr.netmask}";}];
          networkConfig = {
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
        "${infra.namespace.bridge}-dummy0" = {
          enable = true;
          matchConfig.Name = "dummy0";
          linkConfig.ActivationPolicy = "always-up";
          addresses = [{Address = "${infra.net.bridge}.2/32";}];
          networkConfig = {
            Bridge = "br0";
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
        "${infra.namespace.admin}" = {
          enable = true;
          domains = [infra.domain.admin];
          matchConfig.Name = "admin-vlan";
          linkConfig.ActivationPolicy = "always-up";
          networkConfig = {
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
        "${infra.namespace.user}" = {
          enable = true;
          domains = [infra.domain.user];
          matchConfig.Name = "user-vlan";
          linkConfig.ActivationPolicy = "always-up";
          networkConfig = {
            ConfigureWithoutCarrier = true;
            IPv6AcceptRA = "no";
            LinkLocalAddressing = "no";
          };
        };
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
        (adminproxy) {
           import admin
           reverse_proxy ${infra.localhost.ip}:{args[0]}
         }
        (intraproxy) {
           import intra
           reverse_proxy ${infra.localhost.ip}:{args[0]}
         }
        (admincontainer) {
           import admin
           reverse_proxy {args[0]}:${toString infra.port.http}
         }
        (intracontainer) {
           import intra
           reverse_proxy {args[0]}:{args[1]}
         }
      '';
    };
  };
}
