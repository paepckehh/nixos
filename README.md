# nixos
- nixos flakes 
- nixos hardware config files
- nixos env config files
- nixos home-manager files

# Manage Nixos via make (requires pkgs.gnumake)
- make switch                      # switches to a new boot profile for current host/profile
- make boot                        # builds a new boot profile for current host/profile (boot is an alias for build)
- make update                      # updates the flake.lock via flake.nix upstream repos
- make clean                       # garbage collect the nix store and unused store data / profiles (older than >12days), make boot
- make clean-profiles              # removes ALL boot profiles, build a new clean one for current host/profile
- make iso-install                 # builds a new iso file with an auto-installer for the current system
- make iso                         # builds a new live-iso for current system (wip)
- HOST=client make build           # builds a new boot profile for client within the current env
- HOST=client make sdb             # builds a new bootable disk for profile client on disk sdb
- HOST=client LUKS=start make sdb  # builds a new bootable disk for profile client on disk sdb with fulldisk encryption (LUKS)
...

