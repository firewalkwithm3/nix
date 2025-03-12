{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.pinchflat;
in
{
  options.${namespace}.services.pinchflat = with types; {
    enable = mkBoolOpt false "Enable pinchflat";
    port = mkOpt port 8945 "Port to run on";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      pinchflat = {
        image = "ghcr.io/kieraneglin/pinchflat:latest";
        ports = [ "${toString cfg.port}:${toString cfg.port}" ];
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

    ${namespace}.services.caddy.services.pinchflat = {
      port = cfg.port;
      subdomain = "pinchflat";
      domain = "ferngarden.net";
    };
  };
}
