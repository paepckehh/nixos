{
  lib,
  infra,
  ...
}:
lib.mkMerge [
  (import ../../lib/proxy.nix {
    inherit infra;
    name = "chrony1";
  })
  {
    #################
    #-=# SYSTEMD #=-#
    #################
    systemd.services.chrony1 = {
      after = ["network.target"];
      requires = ["network.target"];
      wants = ["network.target"];
      wantedBy = ["multi-user.target"];
      description = "Chrony Service";
      environment = {
        BIND_ADDR = "${infra.localhost.ip}:${toString infra.chrony1.localbind.port.http}";
        BRAND_NAME = "Debitor";
        BRAND_COMPANY_NAME = "Debitor Inkasso GmbH";
        BRAND_LOGO_URL = "https://res.dbt.corp/branding/debitor.png";
        BRAND_LOGO_DARK_URL = "https://res.dbt.corp/branding/debitor_dark.png";
        BRAND_USER_MANUAL_URL = "https://digipedia.dbt.corp/Benutzeranleitungen/timetrack-arbeitszeit-erfassung-anwender";
        BRAND_ADMIN_MANUAL_URL = "https://digipedia.dbt.corp/Benutzeranleitungen/timetrack-zeit-und-urlaubsantrags-erfassung";
        BRAND_AUDIT_MANUAL_URL = "https://git.dbt.corp/crush/chrony/src/branch/main/docs/LAW.md";
        BRAND_LOGIN_LINE1 = "Die Arbeitszeiterfassung der Debitor-Inkasso GmbH.";
        BRAND_LOGIN_LINE2 = "⛅ Eine Debitor interne DebiCloud App. ⛅";
        BRAND_LOGIN_LINE3 = "👍 Hab einen guten Start in den Tag! 👍";
        OIDC_ISSUER = infra.sso.url;
        OIDC_CLIENT_ID = infra.chrony1.hostname;
        OIDC_CLIENT_SECRET = infra.sso.oidc.secret;
        OIDC_REDIRECT_URL = "${infra.chrony1.url}/callback";
        OIDC_ADMIN_GROUP = "debitor-hr";
        OIDC_USER_GROUP_PREFIX = "debitor";
        OIDC_DEPARTMENT_ADMIN_SUFFIX = "head";
        CHRONY_DB_DIR = "/var/lib/${infra.chrony1.hostname}";
        CHRONY_EMAIL_ADMIN = "it@debitor.de";
        CHRONY_EMAIL_HR = "hr@debitor.de";
        CHRONY_REPO = "https://git.dbt.corp/crush/chrony";
        # LEGACY COMPAT MODE
        CHRONY_ADDR = "${infra.localhost.ip}:${toString infra.chrony1.localbind.port.http}";
        # LEGACY COMPAT MODE
        CHRONY_BRAND_NAME = "Debitor";
        CHRONY_BRAND_COMPANY_NAME = "Debitor Inkasso GmbH";
        CHRONY_BRAND_LOGO_URL = "https://res.dbt.corp/branding/debitor.png";
        CHRONY_BRAND_LOGO_DARK_URL = "https://res.dbt.corp/branding/debitor_dark.png";
        CHRONY_BRAND_USER_MANUAL_URL = "https://digipedia.dbt.corp/Benutzeranleitungen/timetrack-arbeitszeit-erfassung-anwender";
        CHRONY_BRAND_ADMIN_MANUAL_URL = "https://digipedia.dbt.corp/Benutzeranleitungen/timetrack-zeit-und-urlaubsantrags-erfassung";
        CHRONY_BRAND_AUDIT_MANUAL_URL = "https://git.dbt.corp/crush/chrony/src/branch/main/docs/LAW.md";
        CHRONY_BRAND_LOGIN_LINE1 = "Die Arbeitszeiterfassung der Debitor-Inkasso GmbH.";
        CHRONY_BRAND_LOGIN_LINE2 = "⛅ Eine Debitor interne DebiCloud App. ⛅";
        CHRONY_BRAND_LOGIN_LINE3 = "👍 Hab einen guten Start in den Tag! 👍";
      };
      serviceConfig =
        infra.systemd.hardening.go
        // {
          ExecStart = "/nix/persist/root/bin/chrony";
          LogsDirectory = infra.chrony1.hostname;
          RuntimeDirectory = infra.chrony1.hostname;
          StateDirectory = infra.chrony1.hostname;
          WorkingDirectory = "/var/lib/${infra.chrony1.hostname}";
        };
    };
  }
]
