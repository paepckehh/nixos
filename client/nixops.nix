{pkgs, ...}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [];
    };
  };

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    olivetin = {
      enable = true;
      user = "root";
      group = "wheel";
      path = with pkgs; [bash];
      settings = {
        pageTitle = "NixOPs";
        showFooter = true;
        showNewVersions = false;
        showNavigation = true;
        logLevel = "INFO";
        authRequireGuestsToLogin = false;
        authLocalUsers = {
          enabled = true;
          users = {
            username = "admin";
            usergroup = "admins";
            password = "$argon2id$v=19$m=65536,t=4,p=12$Aio0SwqUuf7d6oprEO8CIA$aWKTEQsyqyksLlAS4hewV5ijcsUTi1sf4ncPvS40do8"; # start
          };
        };
        accessControlLists = {
          name = "admins";
          permissions = {
            view = true;
            exec = true;
            logs = true;
          };
          matchUsergroups = ["admins"];
          addToEveryAction = true;
        };
        actions = [
          {
            title = "Reboot Local System";
            shell = "reboot";
            icon = "smile";
          }
          {
            title = "Poweroff Local System";
            shell = "poweroff";
            icon = "smile";
            acls = ["admins"];
          }
        ];
        dashboards = {
          title = "Admin Dashboard";
          contents.title = "Restart";
        };
        ListenAddressSingleHTTPFrontend = "127.0.0.1:9292";
      };
    };
  };
}
