{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.radarr;
  dataDir = config.services.radarr.dataDir;
in
{
  options.${namespace}.services.radarr = with types; {
    enable = mkBoolOpt false "Enable radarr - movie fetcher & organiser";
    letterboxd.port = mkOpt port 5000 "Port to run on";
  };

  config = mkIf cfg.enable {
    services.radarr = {
      enable = true;
      group = "media";
    };

    virtualisation.oci-containers = {
      containers.radarr-letterboxd = {
        environment.REDIS_URL = "redis://radarr-letterboxd-redis:6379";
        image = "screeny05/letterboxd-list-radarr:latest";
        ports = [ "${toString cfg.letterboxd.port}:${toString cfg.letterboxd.port}" ];
        extraOptions = [ "--pull=newer" ];
      };

      containers.radarr-letterboxd-redis = {
        image = "redis:6.0";
        extraOptions = [ "--pull=newer" ];
      };
    };

    ${namespace} = {
      backups.modules.radarr = {
        directories = [ dataDir ];
        databases = [
          {
            name = "radarr-logs";
            path = "${dataDir}/logs.db";
          }
          {
            name = "radarr";
            path = "${dataDir}/radarr.db";
          }
        ];
      };
      services.caddy.services.radarr = {
        port = config.${namespace}.services.authentik.port;
        subdomain = "radarr";
        domain = "ferngarden.net";
      };
    };
  };
}
