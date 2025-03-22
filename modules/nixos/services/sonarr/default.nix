{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.sonarr;
in
{
  options.${namespace}.services.sonarr = with types; {
    enable = mkBoolOpt false "Enable sonarr - TV fetcher & organiser";
  };

  config = mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      group = "media";
    };

    ${namespace}.services.caddy.services.sonarr = {
      port = config.${namespace}.services.authentik.port;
      subdomain = "sonarr";
      domain = "ferngarden.net";
    };
  };
}
