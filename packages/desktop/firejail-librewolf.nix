{
  pkgs,
  lib,
  ...
}: {
  ############
  # PROGRAMS #
  ############
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      librewolf = {
        desktop = "${pkgs.librewolf}/share/applications/librewolf.desktop";
        executable = "${pkgs.librewolf}/bin/librewolf";
        profile = "${pkgs.firejail}/etc/firejail/librewolf.profile";
        extraArgs = [
          "--ignore=private-dev"
        ];
      };
    };
  };
}
