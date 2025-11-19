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

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy = {
      enable = true;
      logFormat = lib.mkForce "level INFO";
      globalConfig = ''
                acme_ca ${infra.pki.acme.url}
                acme_ca_root ${infra.pki.certs.rootCA.path}
                email ${infra.pki.acme.contact}
                grace_period 2s
                default_sni ${infra.portal.fqdn}
                fallback_sni ${infra.portal.fqdn}
                renew_interval 24h
                (intranet) {
                  tls {
                    client_auth {
                    mode require_and_verify
                    trusted_ca_cert_file /etc/rootCA.crt
                    trusted_leaf_cert_file /etc/rootCA.crt
            }
          }
        }
      '';
    };
  };
}
