{
  config,
  lib,
  ...
}: {
  ##############################################################################################################
  ##       STRUCTURE   #     DNS         #     AD      #  NETWORK INTERFACE  #   VLANID  #     NETWORK        ##
  ##############################################################################################################
  ## lan               #    lan          #     [-]     #      [native]       #   [-]     #   [10.0.0.0/24]    ##
  ## + infra           #  infra.lan      #     [-]     #      [native]       #   [-]     #   [10.0.0.0/24]    ##
  ## + admin           #  admin.lan      #     [-]     #      [admin]        #   [8]     #   [10.0.8.0/24]    ##
  ## + home            #  home.lan       #   home.lan  #      [server]       #   [16]    #   [10.0.16.0/24]   ##
  ##   +  server       #  home.lan       #   home.lan  #      [server]       #   [16]    #   [10.0.16.0/24]   ##
  ##   +  client       #  home.lan       #   home.lan  #      [client]       #   [128]   #   [10.0.128.0/24]  ##
  ## + iot             #  iot.lan        #     [-]     #      [iot]          #   [250]   #   [10.0.250.0/24]  ##
  ## setup / legacy    #     [-]         #     [-]     #      [setup]        #   [4000]  #   [192.168.0.0/8]  ##
  ##############################################################################################################

  #################
  #-=# IMPORTS #=-#
  #################
  imports = [
    ./unifi/bind.nix
    ./unifi/controller.nix
    ./unifi/prometheus.nix
    ./unifi/kea.nix
    ./unifi/vlans.nix
  ];
}
