{
  inputs,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.pinchflat;
  dataDir = "${podmanVolumeDir}/pinchflat-config";
in
{
  options.${namespace}.services.pinchflat = with types; {
    enable = mkBoolOpt false "Enable pinchflat - YouTube downloader";
    port = mkOpt port 8945 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.pinchflat.rekeyFile = (inputs.self + "/secrets/services/pinchflat.age");

    virtualisation.oci-containers.containers = {
      pinchflat = {
        image = "ghcr.io/kieraneglin/pinchflat:latest";
        ports = [ "${toString cfg.port}:${toString cfg.port}" ];
        environmentFiles = [ config.age.secrets.pinchflat.path ];
        environment = {
          PUID = "1000";
          PGID = "1800";
          TZ = "Australia/Perth";
        };
        volumes = [
          "pinchflat-config:/config"
          "/mnt/volume3/media/pinchflat:/downloads"
        ];
        extraOptions = [ "--pull=newer" ];
      };
    };

    ${namespace} = {
      backups.modules.pinchflat = {
        directories = [ dataDir ];
        databases = [
          {
            name = "pinchflat";
            path = "${dataDir}/_data/db/pinchflat.db";
          }
        ];
      };

      services.caddy.services.pinchflat = {
        port = config.${namespace}.services.authentik.port;
        subdomain = "pinchflat";
        domain = "ferngarden.net";
      };
    };
  };
}
