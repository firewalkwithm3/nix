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
in
{
  options.${namespace}.services.prowlarr = with types; {
    enable = mkBoolOpt false "Enable prowlarr";
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

    ${namespace}.services.caddy.services.prowlarr = {
      port = config.${namespace}.services.authentik.port;
      subdomain = "prowlarr";
      domain = "ferngarden.net";
    };
  };
}
