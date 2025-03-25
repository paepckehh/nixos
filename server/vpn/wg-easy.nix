{
  config,
  pkgs,
  ...
}: {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking = {
    nat = {
      enable = true;
      externalInterface = "wg0";
      # internalInterfaces = ["lo0"];
    };
  };

  ########################
  #-=# VIRTUALISATION #=-#
  ########################
  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers = {
        wg-easy = {
          hostname = "wg-easy";
          image = "ghcr.io/wg-easy/wg-easy";
          ports = ["0.0.0.0:51822:51822" "0.0.0.0:51821:51821"];
          volumes = ["/var/lib/wg-easy:/etc/wireguard"];
          # extraOptions = ["--cap-add NET_ADMIN" "--cap-add SYS_MODULE" "--sysctl 'net.ipv4.conf.all.src_valid_mark=1'" "--sysctl 'net.ipv4.ip_forward=1'"];
          extraOptions = ["--privileged=true"];
          environment = {
            PASSWORD_HASH = "$2a$12$z8e9VadQr8XmxQvKisrIR.H6h1KwdiBjBKLlXHshla7pt7RFhTOTy"; # start
            PORT = "51821"; # webgui
            LANG = "DE";
            WG_PORT = "51822";
            WG_HOST = "127.0.0.1";
          };
        };
      };
    };
  };
}
