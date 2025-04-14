{
  config,
  pkgs,
  ...
}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ../../modules/agenix.nix # needed for tls secret key storage
  ];

  #####################
  #-=# ENVIRONMENT #=-#
  #####################
  environment = {
    shellAliases."console" = ''sudo tail -f /var/syslog-ng/console.txt |  bat --force-colorization --language syslog --paging never'';
    shellAliases."console.err" = ''sudo tail -f /var/syslog-ng/console-err.txt |  bat --force-colorization --language syslog --paging never'';
    shellAliases."console.crit" = ''sudo tail -f /var/syslog-ng/console-crit.txt |  bat --force-colorization --language syslog --paging never'';
    # generate certs (see resources/gencert.sh()
    # openssl req -x509 -newkey ed25519 -sha256 -days 3650 -nodes -keyout syslog.key -out syslog.crt -subj "/CN=me.lan/C=US/O=me.lan" -addext "subjectAltName=IP:..,DNS:.."
    # etc."syslog-ng/cert.key".text = ''----BEGIN PRIVATE KEY''; cleartext key, use agenix instead to store secrets, see below
    etc."syslog-ng/cert.crt".text = ''
      -----BEGIN CERTIFICATE-----
      MIIBpDCCAVagAwIBAgIUcE/2RoriBguvl2v4haB0FpholqIwBQYDK2VwMDMxETAP
      BgNVBAMMCGhvbWUubGFuMQswCQYDVQQGEwJVUzERMA8GA1UECgwIaG9tZS5sYW4w
      HhcNMjUwNDA2MDU1ODMwWhcNMzUwNDA0MDU1ODMwWjAzMREwDwYDVQQDDAhob21l
      LmxhbjELMAkGA1UEBhMCVVMxETAPBgNVBAoMCGhvbWUubGFuMCowBQYDK2VwAyEA
      U3rcMnHy5UsCe/mi0EVvB7zXVrfR0MpdQ++yRzle7vCjfDB6MB0GA1UdDgQWBBSF
      P3kUmx2fp919v9lgdldh3KanYzAfBgNVHSMEGDAWgBSFP3kUmx2fp919v9lgdldh
      3KanYzAPBgNVHRMBAf8EBTADAQH/MCcGA1UdEQQgMB6CCnN5c2xvZy5sYW6HBH8A
      AAGHBMCoCGSHBMCoAGQwBQYDK2VwA0EAn1x2PsIwC7ImESqrLlZT7ftbopG76yQx
      +0zPrkW92LIrCMw4W/lOd4PFs1f+A9XSYvi0VEjw8/j9I/8KnRBFBg==
      -----END CERTIFICATE-----
    '';
  };

  #############
  #-=# AGE #=-#
  #############
  # needs agenix import
  age = {
    secrets = {
      syslog-ng-key = {
        file = ../../modules/resources/syslog-ng-key.age;
        owner = "root";
        group = "wheel";
      };
    };
  };

  ##############
  # NETWORKING #
  ##############
  networking.firewall.allowedTCPPorts = [6514];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    syslog-ng = {
      enable = true;
      extraConfig = ''
        options {
            create-dirs(yes);
            dir-group("wheel");
            dir-owner("root");
            dir-perms(0755);
            group("wheel");
            owner("root");
            perm(0750);
            keep-hostname(yes);
            use-dns(yes);
        };
        source s_local {
            system(); internal();
        };
        source s_network_rfc3164_tls {
                network(
                        ip("0.0.0.0")
                        ip-protocol(4)
                        transport("tls")
                        port(6514) 
                        transport("tls")
                        tls (
                                cert-file("/etc/syslog-ng/cert.crt")
                                key-file("${toString config.age.secrets.syslog-ng-key.path}")
                        )
                        listen-backlog(4096)
                        log-msg-size(65536) 
                        so-reuseport(1)
                );
        };
        destination d_log { file("/var/syslog-ng/console.txt");  };
        destination d_log_err { file("/var/syslog-ng/console-err.txt");  };
        destination d_log_crit { file("/var/syslog-ng/console-crit.txt");  };
        filter f_err  { level(err..emerg); };
        filter f_crit { level(crit..emerg); };
        log { 
                source(s_local); source(s_network_rfc3164_tls); destination(d_log);
                source(s_local); source(s_network_rfc3164_tls); filter(f_err); destination(d_log_err);
                source(s_local); source(s_network_rfc3164_tls); filter(f_crit); destination(d_log_crit);
        };'';
      extraModulePaths = [];
      package = pkgs.syslogng;
    };
  };
}
