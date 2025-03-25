{
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    mediawiki = {
      enable = true;
      name = "PVZ IT MediaWiki";
      httpd.virtualHost = {
        hostName = "wiki.pvz.lan";
        adminAddr = "it@pvz.digital";
        services.mediawiki.httpd.virtualHost.listen = [
          {
            ip = "127.0.0.1";
            port = 8989;
            ssl = false;
          }
        ];
      };
      passwordFile = pkgs.writeText "password" "cardbotnine";
      extraConfig = ''
        # Disable anonymous editing
        $wgGroupPermissions['*']['edit'] = false;
      '';
      extensions = {
        VisualEditor = null;
        TemplateStyles = pkgs.fetchzip {
          # https://www.mediawiki.org/wiki/Extension:TemplateStyles
          url = "https://extdist.wmflabs.org/dist/extensions/TemplateStyles-REL1_40-c639c7a.tar.gz";
          hash = "sha256-YBL0Cs4hDSNnoutNJSJBdLsv9zFWVkzo7m5osph8QiY=";
        };
      };
      nginx = {
        enable = true;
        recommendedProxySettings = true;
        virtualHosts = {
          "wiki.pvz.lan" = {
            locations."/".proxyPass = "http://127.0.0.1:8989";
          };
        };
      };
      prometheus.exporters.nginx = {
        enable = false;
      };
    };
  };

  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    firewall = {
      allowedTCPPorts = [80 443];
    };
  };
}
