{
  config,
  pkgs,
  ...
}: {
  ##################
  #-=# SERVICES #=-#
  ##################

  services = {
    cockpit = {
      enable = false;
      port = 9090;
      settings.WebService.AllowUnencrypted = false;
    };
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
