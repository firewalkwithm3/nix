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
  dataDir = "${config.users.users.lidarr.home}/.config";
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

    ${namespace} = {
      backups.modules.lidarr = {
        directories = [
          "${dataDir}/Lidarr"
          "${dataDir}/beets"
        ];

        databases = [
          {
            name = "lidarr";
            path = "${dataDir}/Lidarr/lidarr.db";
          }
          {
            name = "lidarr-logs";
            path = "${dataDir}/Lidarr/logs.db";
          }
          {
            name = "lidarr-library";
            path = "${dataDir}/beets/library.db";
          }
        ];
      };

      services.caddy.services.lidarr = {
        port = config.${namespace}.services.authentik.port;
        subdomain = "lidarr";
        domain = "ferngarden.net";
      };
    };
  };
}
