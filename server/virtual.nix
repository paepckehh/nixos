{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    # ../server/cockpit.nix
  ];

  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    # kernelModules = ["kvm-intel" "kvm-amd"];
    kernelModules = ["kvm-intel"];
  };

  ##################
  #-=# PROGRAMS #=-#
  ##################
  programs = {
    virt-manager.enable = true;
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security = {
    unprivilegedUsernsClone = lib.mkForce true;
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    hosts = {
      "192.168.122.1" = ["opnborg" "opnborg.lan"];
      "192.168.122.2" = ["opn01" "opn01.lan"];
      "192.168.122.3" = ["opn02" "opn02.lan"];
      "192.168.122.4" = ["opn03" "opn03.lan"];
      "192.168.122.5" = ["opn04" "opn04.lan"];
    };
    nftables.enable = lib.mkForce false;
    firewall.trustedInterfaces = ["virbr0"];
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [quickemu distrobox distrobox-tui dive podman-tui podman-compose docker];
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    containers.enable = true;
    containerd.enable = false;
    lxc.enable = false;
    xen.enable = false;
    vmware.host.enable = false;
    docker = {
      enable = false;
      enableOnBoot = false;
    };
    podman = {
      enable = true;
      dockerCompat = lib.mkForce true;
    };
    lxd = {
      enable = false;
      ui.enable = true;
    };
    virtualbox.host = {
      enable = false;
      enableKvm = false;
    };
    libvirtd = {
      enable = true;
      allowedBridges = ["virbr0"];
      onBoot = "start";
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            })
            .fd
          ];
        };
      };
    };
  };
}
