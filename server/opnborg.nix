{config, ...}: {
  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    opnborg = {
      enable = true;
      extraOptions = {
        "OPN_APIKEY" = "+RIb6YWNdcDWMMM7W5ZYDkUvP4qx6e1r7e/Lg/Uh3aBH+veuWfKc7UvEELH/lajWtNxkOaOPjWR8uMcD";
        "OPN_APISECRET" = "8VbjM3HKKqQW2ozOe5PTicMXOBVi9jZTSPCGfGrHp8rW6m+TeTxHyZyAI1GjERbuzjmz6jK/usMCWR/p";
        "OPN_TARGETS" = "opn00.lan";
        "OPN_HTTPD_ENABLE" = "true";
      };
    };
  };
}
