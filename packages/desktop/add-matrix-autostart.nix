{...}: {
  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./add-matrix.nix
  ];

  #############
  #-=# XDG #=-#
  #############
  xdg = {
    autostart.enable = true;
    xdg.mime = {
      enable = true;
      addedAssociations = {"application/pdf" = "librewolf.desktop";};
      defaultApplication = {"application/pdf" = "librewolf.desktop";};
    };
    configFile."autostart/element-desktop.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Element-desktop
        Exec=/run/wrappers/bin/element-desktop
      '';
    };
  };
}
