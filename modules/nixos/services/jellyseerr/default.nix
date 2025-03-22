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

    ${namespace}.services.caddy.services.jellyseerr = {
      port = cfg.port;
      subdomain = "jellyseerr";
      domain = "fern.garden";
    };
  };
}
