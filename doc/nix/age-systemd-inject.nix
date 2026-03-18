{
  config,
  pkgs,
  ...
}: {
  age.secrets.vmauth-users.file = ./secrets/vmauth-users.age;
  systemd.services.vmauth = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      LoadCredential = "users.yaml:${config.age.secrets.vmauth-users.path}";
      ExecStart = "${pkgs.victoriametrics}/bin/vmauth -envflag.enable -auth.config=$\{CREDENTIALS_DIRECTORY\}/users.yaml";

      # blah blah blah
    };
  };
}
