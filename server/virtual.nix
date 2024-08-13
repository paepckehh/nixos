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
    kernelModules = ["kvm-intel" "kvm-amd"];
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
    nftables.enable = lib.mkForce false;
    firewall.trustedInterfaces = ["virbr0"];
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [quickemu];
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    containers.enable = false;
    containerd.enable = false;
    lxc.enable = false;
    xen.enable = false;
    vmware.host.enable = false;
    docker = {
      enable = false;
      enableOnBoot = false;
    };
    podman = {
      enable = false;
      dockerCompat = true;
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
