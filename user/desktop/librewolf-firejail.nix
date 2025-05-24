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
        executable = "${pkgs.librewolf}/bin/librewolf";
        profile = "${pkgs.firejail}/etc/firejail/librewolf.profile";
        extraArgs = [
          "--ignore=private-dev" # Required for U2F USB stick
          "--env=GTK_THEME=Adwaita:dark" # Enforce dark mode
          "--dbus-user.talk=org.freedesktop.Notifications" # Enable system notifications
        ];
      };
    };
  };
}
