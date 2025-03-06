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
in
{
  options.${namespace}.services.radarr = with types; {
    enable = mkBoolOpt false "Enable radarr";
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

    ${namespace}.services.caddy.services.radarr = {
      port = config.${namespace}.services.authentik.port;
      subdomain = "radarr";
      domain = "ferngarden.net";
    };
  };
}
