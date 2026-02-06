{pkgs, ...}: {
  #######
  # AGE #
  #######
  age.identityPaths = [
    "/root/.ssh/id_ed25519"
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.systemPackages = with pkgs; [ragenix];
}
