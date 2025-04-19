{...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      settings = {
        blocking = {
          blockType = "nxDomain"; # zeroIP
          blockTTL = "1h";
          loading = {
            concurrency = 4;
            refreshPeriod = "6h";
            maxErrorsPerSource = 12;
            downloads = {
              attempts = 12;
              cooldown = "10s";
              timeout = "25s";
              readTimeout = "20s";
              readHeaderTimeout = "15s";
              writeTimeout = "10s";
            };
          };
          allowlists = {
            smartTV = [
              "|
                *.fast.com
                *.nflxso.com
                *.nflxext.com
                *.nflximg.com
                *.nflxvideo.com
                *.netflix.com
                *.netflix.net"
            ];
            ios = [
              "|
                *.apple.com
                *.aaplimg.com
                *.cdn-apple.com
                *.letsencrypt.org
                *.xp.itunes-apple.com.akadns.net"
            ];
            nixos = [
              "|
              *.cache.nixos.org
              *.cachix.org
              *.github.com
              *.github.io
              *.githubassets.com
              *.githubusercontent.com
              *.letsencrypt.org
              *.nixos.pool.ntp.org"
            ];
          };
          denylists = {
            ads = [
              "https://adaway.org/hosts.txt"
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              "https://blocklistproject.github.io/Lists/ads.txt"
              "https://blocklistproject.github.io/Lists/tracking.txt"
            ];
            bad = [
              "|
              *.scw.cloud
              *.nexx360.io"
            ];
            firefox = [
              "|
            *.firefox.com
            *.firefox.org
            *.firefox.net
            *.mozilla.com
            *.mozilla.org
            *.mozilla.net
            *.mozillamessaging.com
            *.thunderbird.net
            *.mozaws.net
            *.mozillademos.org
            *.mozgcp.net
            *.mozaws.net
            *.www-mozilla.fastly-edge.com"
            ];
            gambling = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-only/hosts"
            ];
            fakenews = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"
            ];
            scam = [
              "https://blocklistproject.github.io/Lists/scam.txt"
              "https://blocklistproject.github.io/Lists/redirect.txt"
            ];
            porn = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-only/hosts"
              "https://blocklistproject.github.io/Lists/porn.txt"
            ];
            social = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/social-only/hosts"
            ];
            malware = [
              "https://blocklistproject.github.io/Lists/malware.txt"
              "https://blocklistproject.github.io/Lists/ransomware.txt"
              "https://blocklistproject.github.io/Lists/phishing.txt"
              "https://urlhaus.abuse.ch/downloads/hostfile/"
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/tif.txt"
              "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
              "https://blocklistproject.github.io/Lists/alt-version/ransomware-nl.txt"
            ];
            phishing = [
              "https://urlhaus.abuse.ch/downloads/hostfile/"
              "https://blocklistproject.github.io/Lists/alt-version/phishing-nl.txt"
            ];
            smartTV = [
              "https://blocklistproject.github.io/Lists/smart-tv.txt"
            ];
            ios = [
              "|
              ios.example.com" # needed to avoid allowlist-only mode
            ];
            nixos = [
              "|
              nixos.example.com" # needed to avoid allowlist-only mode
            ];
            windows = [
              "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
            ];
          };
          clientGroupsBlock = {
            default = ["ads" "bad" "firefox" "gambling" "ios" "nixos" "scam" "porn" "fakenews" "malware" "phishing" "windows"];
            smartTV = ["ads" "bad" "firefox" "gambling" "scam" "smartTV" "social" "porn" "fakenews" "malware" "phishing" "windows"];
          };
        };
      };
    };
  };
}
