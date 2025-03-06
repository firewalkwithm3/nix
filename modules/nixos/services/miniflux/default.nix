{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.miniflux;
in
{
  options.${namespace}.services.miniflux = with types; {
    enable = mkBoolOpt false "Enable miniflux";
    port = mkOpt port 8083 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.miniflux.rekeyFile = ../../../../secrets/services/miniflux.age;

    services.miniflux = {
      enable = true;
      adminCredentialsFile = config.age.secrets.miniflux.path;
      config = {
        BASE_URL = "https://rss.ferngarden.net";
        LISTEN_ADDR = "0.0.0.0:8083";
        OAUTH2_PROVIDER = "oidc";
        OAUTH2_REDIRECT_URL = "https://rss.ferngarden.net/oauth2/oidc/callback";
        OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.fern.garden/application/o/miniflux/";
        OAUTH2_USER_CREATION = 1;
      };
    };

    ${namespace}.services.caddy.services.miniflux = {
      port = cfg.port;
      subdomain = "rss";
      domain = "ferngarden.net";
    };
  };
}
