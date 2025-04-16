{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.linkwarden;
in
{
  options.${namespace}.services.linkwarden = with types; {
    enable = mkBoolOpt false "Enable linkwarden - bookmark manager";
    port = mkOpt port 8001 "Port to run on";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      linkwarden = {
        image = "ghcr.io/linkwarden/linkwarden:latest";
        dependsOn = [ "linkwarden-mellisearch" ];
        extraOptions = [
          "--pull=newer"
        ];
        environment = {
          DATABASE_URL = "postgresql://linkwarden@/linkwarden?host=/run/postgresql";
        };
        volumes = [
          "linkwarden:/data/data"
          "/var/run/postgresql:/run/postgresql"
        ];
        ports = [
          "8001:3000"
        ];
      };

      linkwarden-mellisearch = {
        image = "getmeili/meilisearch:v1.12.8";
        extraOptions = [
          "--pull=newer"
          "--network=container:linkwarden"
        ];
        environment = {
        };
        volumes = [
          "linkwarden-mellisearch:/melli_data"
        ];
      };
    };

    ${namespace}.services.caddy.services.linkwarden = {
      port = cfg.port;
      subdomain = "bookmarks";
      domain = "ferngarden.net";
    };
  };
}
