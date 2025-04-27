{pkgs, ...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [./openssh-local-lockdown.nix];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    etc."ssh/ssh_host_ed25519_key.pub".text = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArbsQC2gdtQ9qCC54Khfei/rVMtVjOTiS0sduAi4jDO root@srv-mp'';
    systemPackages = with pkgs; [ragenix rage]; # rustify age
  };
}
