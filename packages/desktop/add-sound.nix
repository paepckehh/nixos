{lib, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    pipewire = {
      enable = lib.mkForce true;
      pulse.enable = lib.mkForce true;
      wireplumber.enable = lib.mkForce true;
      alsa = {
        enable = lib.mkForce true;
        support32Bit = true;
      };
    };
  };

  ##################
  #-=# SECURITY #=-#
  ##################
  security.rtkit.enable = lib.mkForce true;
}
