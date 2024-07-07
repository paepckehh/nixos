{
  config,
  pkgs,
  lib,
  ...
}: {
  ##############
  #-=# BOOT #=-#
  ##############
  boot = {
    initrd = {
      luks.mitigateDMAAttacks = lib.mkDefault true;
    };
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = lib.mkDefault pkgs.linuxPackages_hardened;
    kernelParams = ["slab_nomerge" "page_poison=1" "page_alloc.shuffle=1" "debugfs=off"];
    kernel.sysctl = {
      # kernel
      "kernel.ftrace_enabled" = lib.mkDefault false;
      "kernel.kptr_restrict" = lib.mkOverride 500 2;
      # network
      "net.core.bpf_jit_enable" = lib.mkDefault false;
      "net.ipv4.conf.all.log_martians" = lib.mkDefault true;
      "net.ipv4.conf.all.rp_filter" = lib.mkDefault "1";
      "net.ipv4.conf.default.log_martians" = lib.mkDefault true;
      "net.ipv4.conf.default.rp_filter" = lib.mkDefault "1";
      "net.ipv4.icmp_echo_ignore_broadcasts" = lib.mkDefault true;
      "net.ipv4.conf.all.accept_redirects" = lib.mkDefault false;
      "net.ipv4.conf.all.secure_redirects" = lib.mkDefault false;
      "net.ipv4.conf.default.accept_redirects" = lib.mkDefault false;
      "net.ipv4.conf.default.secure_redirects" = lib.mkDefault false;
      "net.ipv6.conf.all.accept_redirects" = lib.mkDefault false;
    };
    blacklistedKernelModules = [
      "ax25"
      "netrom"
      "rose"
      "adfs"
      "affs"
      "bfs"
      "befs"
      "cramfs"
      "efs"
      "erofs"
      "exofs"
      "freevxfs"
      "f2fs"
      "hpfs"
      "jfs"
      "minix"
      "nilfs2"
      "omfs"
      "qnx4"
      "qnx6"
      "sysv"
    ];
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security = {
    auditd.enable = true;
    allowSimultaneousMultithreading = true; # perf
    lockKernelModules = lib.mkForce true;
    protectKernelImage = lib.mkForce true;
    forcePageTableIsolation = lib.mkForce true;
    apparmor = {
      enable = lib.mkDefault true;
      killUnconfinedConfinables = lib.mkDefault true;
    };
    dhparams = {
      enable = true;
      stateful = false;
      defaultBitSize = "3072";
    };
    doas = {
      enable = false;
      wheelNeedsPassword = lib.mkForce true;
    };
    sudo = {
      enable = false;
      execWheelOnly = lib.mkForce true;
      wheelNeedsPassword = lib.mkForce true;
    };
    sudo-rs = {
      enable = true;
      execWheelOnly = lib.mkForce true;
      wheelNeedsPassword = lib.mkForce true;
    };
    audit = {
      enable = lib.mkForce true;
      failureMode = "panic";
      rules = ["-a exit,always -F arch=b64 -S execve"];
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    memoryAllocator.provider = lib.mkForce "libc";
    # memoryAllocator.provider = lib.mkForce "scudo";
    variables = {
      # SCUDO_OPTIONS = lib.mkDefault "ZeroContents=1";
    };
  };
}