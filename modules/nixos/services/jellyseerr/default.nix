{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.jellyseerr;
  dataDir = "/var/lib/jellyseerr";
in
{
  options.${namespace}.services.jellyseerr = with types; {
    enable = mkBoolOpt false "Enable jellyseerr - Jellyfin requests interface";
    port = mkOpt port 5055 "Port to run on";
  };

  config = mkIf cfg.enable {
    services.jellyseerr = {
      enable = true;
      port = cfg.port;
    };

    ${namespace} = {
      backups.modules.jellyseerr = {
        directories = [ dataDir ];
        databases = [ "${dataDir}/db/db.sqlite3" ];
      };

      services.caddy.services.jellyseerr = {
        port = cfg.port;
        subdomain = "jellyseerr";
        domain = "fern.garden";
      };
    };
  };
}
