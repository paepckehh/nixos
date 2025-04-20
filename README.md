# nixos
- nixos flakes 
- nixos hardware config files
- nixos env config files
- nixos home-manager files

# Manage Nixos via make (requires pkgs.gnumake)
- make update                   # updates the flake.lock via flake.nix upstream repos
- make build                    # builds a new profile for current host/profile
- make switch                   # switches to a new profile build
- make clean                    # garbage collect the nix store and old profiles >12days, build a new clean one for current host/profile
- make clean-profiles           # removes ALL boot profiles, build a new clean one for current host/profile
- make iso-install              # builds a new iso auto-installer for current system
- make iso                      # builds a new live-iso for current system 
- HOST=nixos-client make build  # builds a new profile for nixos-client
- HOST=nixos-client make iso    # builds a new live iso for nixos-client 
...

