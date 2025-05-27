{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./openssh-local-lockdown.nix];

  #######
  # AGE #
  #######
  age.identityPaths = ["/nix/persist/root/.ssh/id_ed25519"];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    etc."ssh/ssh_host_ed25519_key.pub".text = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArbsQC2gdtQ9qCC54Khfei/rVMtVjOTiS0sduAi4jDO root@srv-mp'';
    systemPackages = with pkgs; [age agenix-cli ragenix rage];
  };
}
