{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.navidrome;
in
{
  options.${namespace}.services.navidrome = with types; {
    enable = mkBoolOpt false "Enable navidrome";
    port = mkOpt port 4533 "Port to run on";
  };

  config = mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      settings.Address = "127.0.0.1";
      settings.port = 4533;
      settings.MusicFolder = "/mnt/volume2/media/beets";
      group = "media";
    };

    ${namespace}.services.caddy.services.navidrome = {
      port = cfg.port;
      subdomain = "music";
      domain = "fern.garden";
    };
  };
}
