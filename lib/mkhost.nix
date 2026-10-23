# mkHost: build one nixosSystem entry from a data row (AUDIT.md finding S1).
# The 16 hand-written `nixosSystem { … }` blocks in flake.nix are 6 lines each,
# 5 of which are constant (`system`, `specialArgs`). This collapses that to a
# table so adding a host is a data row, not a copy-paste.
#
# The flake uses it like:
#   nixosConfigurations =
#     lib.mapAttrs' (name: row: lib.nameValuePair name (mkHost inputs row))
#       hostTable;
#
# `inputs` = the flake `inputs` (self, agenix, home-manager, nixpkgs, …).
# `row` shape:
#   {
#     hardware    = ./hardware/hp/t640/default.nix;   # required
#     hosts       = ./hosts/ops.nix;                  # optional (null if absent)
#     role        = ./role/server.nix;                # optional
#     services    = [ ./server/backup/opnborg-systemd.nix … ];
#     dockerRole  = ./role/docker.nix;                # optional (null if absent)
#     useAgenix   = true;                             # adds agenix.nixosModules.default
#     useHomeMgr  = true;                             # adds home-manager.nixosModules.home-manager
#   }
#
# Module order (matches the current flake, which matters for mkDefault/mkForce
# on conflicting attrs): home-manager, hardware, [agenix, hosts, role, docker],
# services. Hosts come before role so a host's mkForce still wins over role
# defaults (the existing file relies on this).
#
# Nothing here is wired into flake.nix until applied (see AUDIT.md).
{
  inputs,
  row,
  ...
}: let
  pkgs = inputs.nixpkgs;
  lib = pkgs.lib;
  infra = (import ../siteconfig/debitor.nix).infra;
  # default every optional row key so callers can omit them
  r =
    {
      hardware = null;
      hosts = null;
      role = null;
      dockerRole = null;
      services = [];
      useAgenix = false;
      useHomeMgr = false;
    }
    // row;
  modules =
    (lib.optional r.useHomeMgr inputs.home-manager.nixosModules.home-manager)
    ++ lib.optional (r.hardware != null) r.hardware
    ++ lib.optional r.useAgenix inputs.agenix.nixosModules.default
    ++ lib.optional (r.hosts != null) r.hosts
    ++ lib.optional (r.role != null) r.role
    ++ lib.optional (r.dockerRole != null) r.dockerRole
    ++ r.services;
in
  pkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs infra;};
    modules = builtins.filter (m: m != null) modules;
  }
