{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.bazarr;
  dataDir = "/var/lib/bazarr";
in
{
  options.${namespace}.services.bazarr = with types; {
    enable = mkBoolOpt false "Enable bazarr - subtitles fetcher";
    port = mkOpt port 6767 "Port to run on";
  };

  config = mkIf cfg.enable {
    services.bazarr = {
      enable = true;
      listenPort = cfg.port;
      group = "media";
    };

    ${namespace} = {
      backups.modules.bazarr = {
        directories = [ dataDir ];
        databases = [
          {
            name = "bazarr";
            path = "${dataDir}/db/bazarr.db";
          }
        ];
      };

      services.caddy.services.bazarr = {
        port = config.${namespace}.services.authentik.port;
        subdomain = "bazarr";
        domain = "ferngarden.net";
      };
    };
  };
}
