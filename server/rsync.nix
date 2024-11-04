{
  config,
  pkgs,
  lib,
  ...
}: {
  # client side exmple
  # rsync --archive --acls --checksum --delete --ignore-times --stats --progress --rsh 'ssh' --verbose /var/www/ rsync@<targetip>:/
  #
  # client side example keypair
  #
  # ~/.ssh/rsync.pub
  # ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5QmLQPORNtjN8xyRQ+iVeexdSJ9HRhkUk3uxJJZty7 rsync
  #
  # ~/.ssh/rsync (0700)
  # -----BEGIN OPENSSH PRIVATE KEY-----
  # b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
  # QyNTUxOQAAACBeUJi0DzkTbYzfMckUPolXnsXUifR0YZFJN7sSSWbcuwAAAIh7BLp6ewS6
  # egAAAAtzc2gtZWQyNTUxOQAAACBeUJi0DzkTbYzfMckUPolXnsXUifR0YZFJN7sSSWbcuw
  # AAAED620gdmYdYNTyoEZfCMIHka3KYbXsSmHZLuVvig01unl5QmLQPORNtjN8xyRQ+iVee
  # xdSJ9HRhkUk3uxJJZty7AAAABXJzeW5j
  # -----END OPENSSH PRIVATE KEY-----

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [rrsync];
    etc."etc/ssh/ssh_host_ed25519_key".text = lib.mkForce ''
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
      QyNTUxOQAAACDSj3wDwPjKu50z6ToVTg9b0aIugRw0i9DqCbOecl5aTwAAAJB+5T5vfuU+
      bwAAAAtzc2gtZWQyNTUxOQAAACDSj3wDwPjKu50z6ToVTg9b0aIugRw0i9DqCbOecl5aTw
      AAAECEswAcn08/ZfyVYk6mJveEBsAx0wH4hyCNk/GzKjbjj9KPfAPA+Mq7nTPpOhVOD1vR
      oi6BHDSL0OoJs55yXlpPAAAAC21lQG5peG9zLW1wAQI=
      -----END OPENSSH PRIVATE KEY-----
    '';
    etc."etc/ssh/ssh_host_ed25519_key.pub".text = lib.mkForce ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKPfAPA+Mq7nTPpOhVOD1vRoi6BHDSL0OoJs55yXlpP me@nixos-mp
    '';
  };

  ###############
  #-=# USERS #=-#
  ###############
  users = {
    users = {
      "rsync" = {
        isNormalUser = true;
        description = "rsync daemon user";
        initialHashedPassword = null; # disable interactive login
        uid = 6688;
        group = "rsync";
        createHome = true;
        openssh.authorizedKeys.keys = [
          ''command="${pkgs.rrsync}/bin/rrsync /var/www",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5QmLQPORNtjN8xyRQ+iVeexdSJ9HRhkUk3uxJJZty7'' # sample
          ''command="${pkgs.rrsync}/bin/rrsync /var/www",restrict sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIA44D5TOInaQRb7DrUzMVOciR3kdXhQK9ghkjaZiZJAFAAAABHNzaDo='' # git@paepcke.de
        ];
      };
    };
    groups.rsync.gid = 6688;
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    openssh = {
      enable = lib.mkForce true;
      allowSFTP = false;
      settings = {
        AllowUsers = ["rsync"];
        AllowAgentForwarding = false;
        AllowStreamLocalForwarding = false;
        AllowTcpForwarding = false;
        AuthenticationMethods = "publickey";
        ChallengeResponseAuthentication = false;
        Ciphers = ["chacha20-poly1305@openssh.com"];
        KexAlgorithms = ["curve25519-sha256" "curve25519-sha256@libssh.org"];
        StrictModes = true;
        LogLevel = "INFO";
        PasswordAuthentication = false;
        PubkeyAcceptedAlgorithms = "ssh-ed25519,sk-ssh-ed25519@openssh.com";
        PubkeyAuthentication = "yes";
        PermitRootLogin = "no";
        UseDns = false;
        UsePAM = true;
        X11Forwarding = false;
      };
      startWhenNeeded = true;
      openFirewall = true;
      hostKeys = [
        {
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
        }
      ];
    };
  };
}
