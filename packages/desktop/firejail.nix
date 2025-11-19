{
  pkgs,
  lib,
  ...
}: {
  ###############
  # ENVIRONMENT #
  ###############
  environment.systemPackages = [
    (
      let
        packages = with pkgs; [librewolf];
      in
        pkgs.runCommand "firejail-icons"
        {
          preferLocalBuild = true;
          allowSubstitutes = false;
          meta.priority = -1;
        }
        ''
          mkdir -p "$out/share/icons"
          ${lib.concatLines (map (pkg: ''
              tar -C "${pkg}" -c share/icons -h --mode 0755 -f - | tar -C "$out" -xf -
            '')
            packages)}
          find "$out/" -type f -print0 | xargs -0 chmod 0444
          find "$out/" -type d -print0 | xargs -0 chmod 0555
        ''
    )
  ];
  ############
  # PROGRAMS #
  ############
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      jailwolf = {
        executable = "${pkgs.librewolf}/bin/librewolf";
        profile = "${pkgs.firejail}/etc/firejail/librewolf.profile";
        extraArgs = [
          # "--env=GTK_THEME=Adwaita:dark"
          # "--env=NIXOS_OZONE_WL=1"
        ];
      };
    };
  };
}
