{lib, ...}: {
  ##############
  # NETWORKING #
  ##############
  networking.usePredictableInterfaceNames = lib.mkForce true;

  ###########
  # SYSTEMD #
  ###########
  systemd = {
    network = {
      wait-online = {
        enable = true;
        ignoredInterfaces = ["lo"];
      };
      networks = {
        "cloud" = {
          enable = true;
          domains = ["corp" "home.corp" "home.corp" "admin.corp"];
          dns = ["10.50.6.53"];
          matchConfig.Name = "lo*";
          addresses = [
            #### admim
            {Address = "10.50.0.100/23";} # host native network access /23
            {Address = "10.50.0.108/32";} # pki
            {Address = "10.50.0.126/32";} # ldap
            {Address = "10.50.0.151/32";} # webacme
            {Address = "10.50.0.152/32";} # webpki
            {Address = "10.50.0.153/32";} # webmtls
            #### user
            {Address = "10.50.6.25/32";} # smtp
            {Address = "10.50.6.53/32";} # dns
            {Address = "10.50.6.100/23";} # host native network access /23
            {Address = "10.50.6.117/32";} # cloud
            {Address = "10.50.6.119/32";} # search
            {Address = "10.50.6.126/32";} # ldap iam
            {Address = "10.50.6.143/32";} # sso
            {Address = "10.50.6.154/32";} # translate-lama
          ];
        };
      };
    };
  };
}
