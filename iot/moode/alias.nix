{
  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases = {
      # moode.lan
      "moode" = "make -C /etc/nixos/iot/moode moode";
      "moode.btop" = "make -C /etc/nixos/iot/moode moode-btop";
      "moode.install" = "make -C /etc/nixos/iot/moode moode-install";
      "moode.update" = "make -C /etc/nixos/iot/moode moode-update";
      "moode.reboot" = "make -C /etc/nixos/iot/moode moode-reboot";
      "moode.ro" = "make -C /etc/nixos/iot/moode moode-ro";
      "moode.rw" = "make -C /etc/nixos/iot/moode moode-rw";
      # moode2.lan
      "moode2" = "make -C /etc/nixos/iot/moode moode2";
      "moode2.btop" = "make -C /etc/nixos/iot/moode moode2-btop";
      "moode2.install" = "make -C /etc/nixos/iot/moode moode2-install";
      "moode2.update" = "make -C /etc/nixos/iot/moode moode2-update";
      "moode2.reboot" = "make -C /etc/nixos/iot/moode moode2-reboot";
      "moode2.ro" = "make -C /etc/nixos/iot/moode moode2-ro";
      "moode2.rw" = "make -C /etc/nixos/iot/moode moode2-rw";
    };
  };
}
