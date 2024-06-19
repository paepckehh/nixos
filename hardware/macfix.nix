{
  config,
  lib,
  ...
}: {
  ##############
  #-=# BOOT #=-#
  ##############

  boot = {
    blacklistedKernelModules = ["bluetooth" "facetimehd" "snd_hda_intel"];
  };

  #################
  #-=# SYSTEMD #=-#
  #################

  systemd = {
    services = {
      disable-nvme-d3cold = {
        enable = false;
        restartIfChanged = false;
      };
      btattach-bcm2e7c = {
        enable = false;
        restartIfChanged = false;
      };
      bluethooth = {
        enable = false;
        restartIfChanged = false;
      };
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################

  services = {
    pipewire = {
      enable = lib.mkForce false;
      alsa.enable = false;
      pulse.enable = false;
    };
  };

  ###############
  #-=# SOUND #=-#
  ###############

  sound.enable = false;
}
