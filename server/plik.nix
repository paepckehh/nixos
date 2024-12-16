{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    plikd = {
      enable = true;
      openFirewall = true;
      settings = {
        ListenPort = 9191;
        ListenAddress = "0.0.0.0";
        MetricsPort = 0;
        MetricsAddress = "0.0.0.0";
        AbuseContac = "it@pvz.digital";
        MaxFileSizeStr = "4GB";
        MaxUserSizeStr = "4GB";
        DefaultTTLStr = "1d";
        MaxTTLStr = "5d";
        FeatureAuthentication = "disabled";
        FeatureOneShot = "enabled"; # Upload with files that are automatically deleted after the first download
        FeatureRemovable = "disabled"; # Upload with files that anybody can delete
        FeatureStream = "disabled"; # Upload with files that are not stored on the server
        FeaturePassword = "enabled"; # Upload that are protected by HTTP basic auth login/password
        FeatureComments = "disabled"; # Upload with markdown comments / forced -> default
        FeatureSetTTL = "enabled"; # When disabled upload TTL is always set to DefaultTTL
        FeatureExtendTTL = "disabled"; # Extend upload expiration date by TTL each time it is accessed
        FeatureClients = "enabled"; # Display the clients download button in the web UI
        FeatureGithub = "disabled"; # Display the source code link in the web UI
        FeatureText = "disabled"; # Upload text dialog
      };
    };
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
