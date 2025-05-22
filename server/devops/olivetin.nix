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
            acls = ["admins" "guests"];
          }
          {
            title = "Poweroff Local System";
            shell = "poweroff";
            icon = "&#128064;";
            acls = ["admins"];
          }
          {
            title = "Update Local System [switch]";
            shell = "/run/current-system/sw/bin/make -C /etc/nixos update switch";
            icon = "&#x2699;";
            acls = ["admins"];
          }
          {
            title = "Update Local System [reboot]";
            shell = "/run/current-system/sw/bin/make -C /etc/nixos update boot && reboot";
            icon = "&#x2699;";
            acls = ["admins"];
          }
          {
            title = "Flush DNS Cache";
            shell = "systemctl restart systemd-resolved.service";
            icon = "&#128260;";
            acls = ["admins"];
          }
          {
            title = "Reboot node moode.lan [via ssh]";
            shell = "ssh -t -p 6623 me@moode.lan 'reboot'";
            icon = "&#x1F6E0";
            acls = ["admins" "guests"];
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
