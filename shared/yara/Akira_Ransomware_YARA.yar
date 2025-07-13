rule Akira_Ransomware_Indicators {
    meta:
        description = "Detects Akira ransomware and related tools based on file names and hashes"
        author = "sl33pydata"
        date = "2024-12-11"
        reference = "User-provided IOCs"
    
    strings:
        $file_names = /w\.exe|Win\.exe|AnyDesk\.exe|Gcapi\.dll|Sysmon\.exe|Config\.yml|Rclone\.exe|Winscp\.rnd|WinSCP-6\.1\.2-Setup\.exe|Akira_v2|Megazord|VeeamHax\.exe|Veeam-Get-Creds\.ps1|PowershellKerberos|sshd\.exe|ipscan-3\.9\.1-setup\.exe|winrar-x64-623\.exe/
        $hashes = {
            d2fd0654710c27dcf37b6c1437880020824e161dd0bf28e3a133ed777242a0ca
            dcfa2800754e5722acf94987bb03e814edcb9acebda37df6da1987bf48e5b05e
            bc747e3bf7b6e02c09f3d18bdd0e64eef62b940b2f16c9c72e647eec85cf0138
            73170761d6776c0debacfbbc61b6988cb8270a20174bf5c049768a264bb8ffaf
            1b60097bf1ccb15a952e5bcc3522cf5c162da68c381a76abc2d5985659e4d386
            aaa647327ba5b855bedea8e889b3fafdc05a6ca75d1cfd98869432006d6fecc9
            7d6959bb7a9482e1caa83b16ee01103d982d47c70c72fdd03708e2b7f4c552c4
            36cc31f0ab65b745f25c7e785df9e72d1c8919d35a1d7bd4ce8050c8c068b13c
            3298d203c2acb68c474e5fdad8379181890b4403d6491c523c13730129be3f75
            0ee1d284ed663073872012c7bde7fac5ca1121403f1a5d2d5411317df282796c
            ffd9f58e5fe8502249c67cad0123ceeeaa6e9f69b4ec9f9e21511809849eb8fc
            aaa6041912a6ba3cf167ecdb90a434a62feaf08639c59705847706b9f492015d
            18051333e658c4816ff3576a2e9d97fe2a1196ac0ea5ed9ba386c46defafdb88
            5e1e3bf6999126ae4aa52146280fdb913912632e8bac4f54e98c58821a307d32
            8317ff6416af8ab6eb35df3529689671a700fdb61a5e6436f4d6ea8ee002d694
            892405573aa34dfc49b37e4c35b655543e88ec1c5e8ffb27ab8d1bbf90fc6ae0
            7a647af3c112ad805296a22b2a276e7c
        }
        $additional_hashes = {
            0b5b31af5956158bfbd14f6cbf4f1bca23c5d16a40dbf3758f3289146c565f43
            0d700ca5f6cc093de4abba9410480ee7a8870d5e8fe86c9ce103eec3872f225f
            a2df5477cf924bd41241a3326060cc2f913aff2379858b148ddec455e4da67bc
            03aa12ac2884251aa24bf0ccd854047de403591a8537e6aba19e822807e06a45
            2e88e55cc8ee364bf90e7a51671366efb3dac3e9468005b044164ba0f1624422
            40221e1c2e0c09bc6104548ee847b6ec790413d6ece06ad675fff87e5b8dc1d5
            5ea65e2bb9d245913ad69ce90e3bd9647eb16d992301145372565486c77568a2
            643061ac0b51f8c77f2ed202dc91afb9879f796ddd974489209d45f84f644562
            6f9d50bab16b2532f4683eeb76bd25449d83bdd6c85bf0b05f716a4b49584f84
            fef09b0aa37cbdb6a8f60a6bd8b473a7e5bffdc7fd2e952444f781574abccf64
        }

    condition:
        any of ($file_names*) or any of ($hashes*) or any of ($additional_hashes*)
}
