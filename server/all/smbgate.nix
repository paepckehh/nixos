# smb security gateway
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
  networking = {
    extraHosts = "${infra.smbgate.ip} ${infra.smbgate.hostname} ${infra.smbgate.fqdn}";
    firewall = {
      enable = lib.mkForce true;
      allowPing = lib.mkForce true;
      allowedTCPPorts = [infra.port.smb.tcp];
      allowedUDPPorts = [infra.port.smb.quic];
    };
  };

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd = {
    network.networks.${infra.namespace.user}.addresses = [{Address = "${infra.smbgate.ip}/32";}];
    tmpfiles.rules = infra.smbgate.mountpoints;
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = infra.smbgate.users;
    groups = infra.smbgate.groups;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    samba-wsdd.enable = lib.mkForce false;
    samba = {
      enable = true;
      smbd.enable = true;
      nmbd.enable = lib.mkForce false;
      nsswins = lib.mkForce false;
      usershares.enable = lib.mkForce false;
      winbindd.enable = lib.mkForce false;
      settings = {
        # infra.smbgate.shares;
        global = {
          "bind interfaces only" = "yes";
          "case sensitive" = "yes";
          "disable spoolss" = "yes";
          "deadtime" = "5";
          "guest account" = "nobody";
          "hostname lookups" = "no";
          "hosts deny" = "0.0.0.0/0";
          "hosts allow" = infra.cidr.user;
          "interfaces" = "${infra.smbgate.lock.interface} ${infra.cidr.user}";
          "invalid users" = ["me" "root"];
          "load printers" = "no";
          "passwd program" = "/run/wrappers/bin/passwd %u";
          "printing" = "bsd";
          "printcap name" = "/dev/null";
          "server role" = "STANDALONE";
          "security" = "user";
          "smb3 directory leases" = "auto";
          "smb3 unix extensions" = "yes";
          "map to guest" = "bad user";
          "unicode" = "yes";
          "unix charset" = "UTF-8";
          "unix password sync" = "no";
          "use sendfile" = "yes";
          "workgroup" = "WORKGROUP";
          # SERVER HARDENING
          "server signing" = "mandatory";
          "server string" = "SMB Security GateWay %h : %v";
          "server smb encrypt" = "required";
          "server smb transports" = "tcp"; # target: quic
          "server smb3 encryption algorithms" = "AES-128-GCM, AES-256-GCM";
          "server smb3 signing algorithms" = "AES-128-GMAC";
          "server max protocol" = "SMB3_11";
          "server min protocol" = "SMB3_11";
          # CLIENT HARDENING
          "client ipc signing" = "required";
          "client protection" = "encrypt";
          "client smb encrypt" = "required";
          "client smb transports" = "tcp"; # target: quic
          "client smb3 encryption algorithms" = "AES-128-GCM, AES-256-GCM";
          "client smb3 signing algorithms" = "AES-128-GMAC";
          "client max protocol" = "SMB3_11";
          "client min protocol" = "SMB3_11";
          # QUIC TLS
          "tls enabled" = "no";
          "tls cafile" = "tls/ca.pem";
          "tls certfile" = "tls/cert.pem";
          "tls trust system cas" = "no";
          # CACHE
          # "additional dns hostnames" = infra.smbgate.alias; FQDN alias
          # "client use kerberos = "required"; ADS integrated only
          # "kerberos encryption types" = "strong"; ADS integrated only
          # QUIC: https://learn.microsoft.com/en-us/windows-server/storage/file-server/smb-over-quic?tabs=windows-admin-center%2Cpowershell2%2Cwindows-admin-center1
        };
      };
    };
  };
}
