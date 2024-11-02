{
  config,
  lib,
  ...
}: {

  ##################
  #-=# SERVICES #=-#
  ##################
  services = { 
    mopidy = {
      enable = true;
      extensionPackages = with pkgs; [ mopidy-spotify mopidy-iris mopidy-tidal mopidy-tunein mopidy-youtube mopidy-podcast mopidy-soundcloud ]
  };
}
