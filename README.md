# nixos
- nixos flakes 
- nixos hardware config files
- nixos env config files
- nixos home-manager files

# see flake.nix for individual hosts / server 

# Manage Nixos via make (requires pkgs.gnumake)
## => manage and update current boot profiles <=
- make switch                       # switches to a new boot profile for current host/profile
- make boot                         # builds a new boot profile for current host/profile (boot is an alias for build)
- make update                       # updates the flake.lock via flake.nix upstream repos
- make clean                        # garbage collect the nix store and unused store data / profiles (older than >12days), make boot
- make clean-profiles               # removes ALL boot profiles, build a new clean one for current host/profile
- [...]                             # see Makefile, make allows to chain tasks, eg.: make update switch

## => add new nixos boot profiles on current disk (requires compatible disk layout) <=
- TARGET=client make build          # builds a new boot profile for targetos 'client'  
- TARGET=kiosk make build           # builds a new boot profile for targetos 'kiosk'

## => build new bootable autoinstaller-iso-image, installes nixos offfline, full automatic (will auto-wipe ALL target-system disks, no interface) <=
- make installer                    # builds a new auto-installer-iso (TARGET=nixos, LUKS='please define in iso-autoinstaller.nix')

## => build new os on target-disk device <=
- TARGET=kiosk make sdb                  # builds a new bootable disk for profile 'kiosk' on disk sdb
- TARGET=client LUKS=start make sdb      # builds a new bootable disk for profile 'client' on disk sdb with fulldisk encryption (LUKS), password: 'start'
