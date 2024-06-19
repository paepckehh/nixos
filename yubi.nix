{
  config,
  pkgs,
  lib,
  ...
}: {

  ##################
  #-=# SECURITY #=-#
  ##################
  
  security = {
    pam = { 
    services = {
     login.u2fAuth = true;
     sudo.u2fAuth = true;
    };
     yubico = {
      enable = true;
      debug = true;
      control = "required";
      mode = "challenge-response";
      id = "012345";
    };
  };};

  #####################
  #-=# ENVIRONMENT #=-#
  #####################

  environment = {
    systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
    ];

  ##################
  #-=# SERVICES #=-#
  ##################

  services = {
    pcscd.enable = true;
    udev.extraRules = ''
       ACTION=="remove",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="0407",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl lock-sessions" '';
    };
  }
