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
    enable = mkBoolOpt false "Enable lidarr";
    port = mkOpt port 9000 "Port to run on";
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
      port = cfg.port;
      subdomain = "lidarr";
      domain = "ferngarden.net";
    };
  };
}
