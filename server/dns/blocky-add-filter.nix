{...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    blocky = {
      settings = {
        blocking = {
          blockType = "zeroIP";
          blockTTL = "15m";
          loading = {
            concurrency = 4;
            refreshPeriod = "6h";
            maxErrorsPerSource = 30;
            downloads = {
              attempts = 12;
              cooldown = "360s";
              timeout = "120s";
              readTimeout = "60s";
              readHeaderTimeout = "20s";
              writeTimeout = "20s";
            };
          };
          # allowlists = {};
          denylists = {
            ads = [
              "https://adaway.org/hosts.txt"
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              "https://blocklistproject.github.io/Lists/ads.txt"
              "https://blocklistproject.github.io/Lists/tracking.txt"
            ];
            gambling = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-only/hosts"
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
            fakenews = [
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"
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
            windows = [
              "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
            ];
            smartTV = [
              "https://blocklistproject.github.io/Lists/smart-tv.txt"
            ];
          };
          clientGroupsBlock = {
            default = ["ads" "gambling" "scam" "porn" "fakenews" "malware" "phishing" "windows"];
            smartTV = ["smartTV" "ads" "gambling" "scam" "social" "porn" "fakenews" "malware" "phishing" "windows"];
          };
        };
      };
    };
  };
}
