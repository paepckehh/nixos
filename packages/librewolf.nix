{pkgs, ...}: {
  ############
  # PROGRAMS #
  ############
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      librewolf = {
        executable = "${pkgs.librewolf}/bin/librewolf";
        profile = "${pkgs.firejail}/etc/firejail/librewolf.profile";
        extraArgs = [
          "--ignore=private-dev"
          "--env=GTK_THEME=Adwaita:dark"
          "--dbus-user.talk=org.freedesktop.Notifications"
        ];
      };
    };
  };
}
