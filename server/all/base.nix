# global nix cloud server config basline, docker, reverse proxy, ...
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
  #######
  # AGE #
  #######
  age.identityPaths = ["/nix/persist/root/.ssh/id_ed25519"];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    etc."ssh/ssh_host_ed25519_key.pub".text = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArbsQC2gdtQ9qCC54Khfei/rVMtVjOTiS0sduAi4jDO root@srv-mp'';
    systemPackages = with pkgs; [ragenix goaccess];
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall.allowedTCPPorts = infra.port.webapps;
    firewall.allowedUDPPorts = infra.port.webapps;
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.services = {
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

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation.oci-containers.backend = "podman"; # global: docker or podman

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    nginx.defaultListen = lib.mkForce [
      {
        addr = "127.0.0.1";
        ssl = false;
      }
    ];
    caddy = {
      enable = true;
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
           @not_intranet { not remote_ip ${infra.cidr.user} }
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
           reverse_proxy {args[0]}:${toString infra.port.http}
         }
      '';
    };
  };
}
