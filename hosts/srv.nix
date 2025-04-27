{config, ...}: {
  #############
  #-=# AGE #=-#
  #############
  age.secrets = {
    ssh_host_ed25519_key_srv = {
      file = ../modules/resources/ssh_host_ed25519_key_srv.age;
      owner = "root";
      group = "wheel";
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment.etc = {
    "ssh/ssh_host_ed25519_key".source = ./resources/ssh.srv;
    "ssh/ssh_host_ed25519_key.pub".text = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIArbsQC2gdtQ9qCC54Khfei/rVMtVjOTiS0sduAi4jDO root@srv-mp'';
  };
}
