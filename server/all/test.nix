# PORTAL => HOMER: web gui test
{
  config,
  pkgs,
  lib,
  ...
}: let
  ############################
  #-=# GLOBAL SITE IMPORT #=-#
  ############################
  infra = (import ../../siteconfig/config.nix).infra;
in {
  ####################
  #-=# NETWORKING #=-#
  ####################
  networking.extraHosts = "${infra.test.ip} ${infra.test.hostname} ${infra.test.fqdn}.";

  #################
  #-=# SYSTEMD #=-#
  #################
  systemd.network.networks."${infra.namespace.user}".addresses = [{Address = "${infra.test.ip}/32";}];

  ##################
  #-=# SERVICES #=-#
  ##################
  services = {
    caddy.virtualHosts."${infra.test.fqdn}" = {
      listenAddresses = [infra.test.ip];
      extraConfig = ''
        import intra
        request_body { max_size 1MB }
        templates
        respond <<PARROT

        ## Request Summary:
        Method         : {{ .Req.Method }}
        URI            : {{ .Req.RequestURI }}
        Protocol       : {{ .Req.Proto }}
        Remote Address : {{ .Req.RemoteAddr }}
        Server         : {{ .Req.Host }}
        Connection     : {{ if .Req.TLS }}HTTPS{{ else }}HTTP{{ end }}
        Timestamp      : {{ now | date "2006-01-02 15:04:05 UTC" }}

        {{ if .Req.TLS -}}
        ## TLS Details:
        Version        : {tls_version}
        Cipher Suite   : {tls_cipher}
        Protocol       : {{ .Req.TLS.NegotiatedProtocol }}
        SNI            : {{ .Req.TLS.ServerName }}
        {{- end }}

        ## Headers:
        {{ if .Req.Host }}Host: {{ .Req.Host }}{{ end }}
        {{ range $header, $values := .Req.Header }}{{ range $values }}{{ printf "%s: %s\n" $header . }}{{ end }}{{ end -}}

        {{ if .Req.URL.RawQuery }}
        ## Query Parameters:
        {{ range $param, $values := .Req.URL.Query }}{{ range $values}}{{printf "%s: %s\n" $param . }}{{ end }}{{ end -}}
        {{ end -}}

        {{ if or (eq .Req.Method "POST") (eq .Req.Method "PUT") (eq .Req.Method "PATCH") }}
        ## Request Body:
        {{ placeholder "http.request.body" }}
        {{ end }}
        PARROT
      '';
    };
  };
}
