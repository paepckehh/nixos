# improvements-part5/lib/harden.nix
# [S4] Shared systemd service hardening block.
#
# ~10 service modules (chrony1/2/3, and others) each copy-paste the same
# ~40-line serviceConfig block:
#   DynamicUser, ProtectSystem="strict", MemoryDenyWriteExecute, NoNewPrivileges,
#   RestrictAddressFamilies, SystemCallFilter = ["@system-service" ...], etc.
#
# Fold it into one place. Callers do:
#   systemd.services.<name>.serviceConfig =
#     (import ./lib/harden.nix) { lib = pkgs.lib; stateDir = infra.chrony1.hostname; }
#     // {
#       ExecStart = "/nix/persist/root/bin/chrony";
#       WorkingDirectory = "/var/lib/${infra.chrony1.hostname}";
#     };
#
# Only the per-service bits (ExecStart, WorkingDirectory, dir names) stay at
# the call site; the 40 lines of common hardening live here once.
{
  lib,
  stateDir ? null,
  capNetBind ? true,
  ...
}: let
  # only set *Directory attrs when a dir name is given (some services use none)
  dirAttrs =
    if stateDir != null
    then {
      LogsDirectory = stateDir;
      RuntimeDirectory = stateDir;
      StateDirectory = stateDir;
    }
    else {};
  caps =
    if capNetBind
    then ["CAP_NET_BIND_SERVICE"]
    else [];
in
  {
    AmbientCapabilities = caps;
    CapabilityBoundingSet = caps;
    DynamicUser = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    NonBlocking = true;
    PrivateDevices = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectSystem = "strict";
    Restart = "on-failure";
    RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = ["@system-service" "@chown" "~@aio" "~@keyring" "~@memlock" "~@setuid" "~@timer"];
    KillMode = "process";
  }
  // dirAttrs
