{
  config,
  pkgs,
  lib,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  # imports = [
  # ];

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
    hosts = {
      "192.168.122.1" = ["opnborg" "opnborg.lan"];
      "192.168.122.2" = ["opn01" "opn01.lan"];
      "192.168.122.3" = ["opn02" "opn02.lan"];
      "192.168.122.4" = ["opn03" "opn03.lan"];
      "192.168.122.5" = ["opn04" "opn04.lan"];
      "192.168.122.9" = ["opn00" "opn00.lan"];
    };
    nftables.enable = lib.mkForce false;
    firewall.trustedInterfaces = ["virbr0"];
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    # systemPackages = with pkgs; [quickemu distrobox distrobox-tui dive spice spice-gtk spice-protocol virt-viewer];
    systemPackages = with pkgs; [spice spice-gtk spice-protocol virt-viewer];
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      allowedBridges = ["virbr0"];
      onBoot = "start";
      qemu = {
        package = pkgs.qemu_full;
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
