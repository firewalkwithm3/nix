{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.prowlarr;
  dataDir = "/var/lib/prowlarr";
in
{
  options.${namespace}.services.prowlarr = with types; {
    enable = mkBoolOpt false "Enable prowlarr - tracker indexer";
    flaresolverr.port = mkOpt port 8191 "Port to run on";
  };

  config = mkIf cfg.enable {
    services.prowlarr = {
      enable = true;
    };

    virtualisation.oci-containers.containers = {
      flaresolverr = {
        image = "ghcr.io/flaresolverr/flaresolverr:latest";
        ports = [ "${toString cfg.flaresolverr.port}:${toString cfg.flaresolverr.port}" ];
        extraOptions = [ "--pull=newer" ];
      };
    };

    ${namespace} = {
      backups.modules.prowlarr = {
        directories = [ dataDir ];
        databases = [
          {
            name = "prowlarr-logs";
            path = "${dataDir}/logs.db";
          }
          {
            name = "prowlarr";
            path = "${dataDir}/prowlarr.db";
          }
        ];
      };
      services.caddy.services.prowlarr = {
        port = config.${namespace}.services.authentik.port;
        subdomain = "prowlarr";
        domain = "ferngarden.net";
      };
    };
  };
}
