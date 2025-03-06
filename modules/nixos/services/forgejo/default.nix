{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.forgejo;
in
{
  options.${namespace}.services.forgejo = with types; {
    enable = mkBoolOpt false "Enable forgejo";
    port = mkOpt port 3000 "Port to run on";
  };

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      database = {
        type = "postgres";
        socket = "/var/run/postgresql";
      };
      settings.DEFAULT = {
        APP_NAME = "Fern's Git Server";
        RUN_MODE = "prod";
      };
      settings.server = {
        DOMAIN = "git.fern.garden";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = cfg.port;
        ROOT_URL = "https://git.fern.garden";
      };
      settings.service.DISABLE_REGISTRATION = true;
    };

    ${namespace}.services.caddy.services.forgejo = {
      port = cfg.port;
      subdomain = "git";
      domain = "fern.garden";
    };
  };
}
