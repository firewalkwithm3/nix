{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.lidarr;
in
{
  options.${namespace}.services.lidarr = with types; {
    enable = mkBoolOpt false "Enable lidarr - music fetcher & organiser";
  };

  config = mkIf cfg.enable {
    systemd.services.lidarr.path = with pkgs; [
      beets
    ];

    services.lidarr = {
      enable = true;
      group = "media";
    };

    ${namespace}.services.caddy.services.lidarr = {
      port = config.${namespace}.services.authentik.port;
      subdomain = "lidarr";
      domain = "ferngarden.net";
    };
  };
}
