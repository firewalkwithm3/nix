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
    enable = mkBoolOpt false "Enable sonarr";
    port = mkOpt port 0 "Port to run on";
  };

  config = mkIf cfg.enable {
    services.sonarr = {
      enable = true;
      group = "media";
    };

    ${namespace}.services.caddy.services.sonarr = {
      port = cfg.port;
      subdomain = "sonarr";
      domain = "ferngarden.net";
    };
  };
}
