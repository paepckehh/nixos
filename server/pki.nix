{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    step-ca = {
      enable = true;
      address = "0.0.0.0";
      port = "8443";
      openFirewall = true;
      intermediatePasswordFile = "/run/keys/smallstep-password";
      # settings = {}
      # run step ca init
      # then import ca.json via builtins.fromJSON
      # adapat storagePath: /var/lib/step-ca/db
    };
  };

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    systemPackages = with pkgs; [step-kms-plugin step-cli];
    shellAliases = {};
    variables = {};
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [];
    };
  };
}
