{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.audiobookshelf;
  dataDir = "/var/lib/${config.services.audiobookshelf.dataDir}";
in
{
  options.${namespace}.services.audiobookshelf = with types; {
    enable = mkBoolOpt false "Enable audiobookshelf - audiobooks manager";
    port = mkOpt port 8081 "Port to run on";
  };

  config = mkIf cfg.enable {
    services.audiobookshelf = {
      enable = true;
      port = cfg.port;
      group = "media";
    };

    ${namespace} = {
      backups.modules.audiobookshelf = {
        directories = [ dataDir ];
        databases = [ "${dataDir}/config/absdatabase.sqlite" ];
      };
      services.caddy.services.audiobookshelf = {
        port = cfg.port;
        subdomain = "audiobooks";
        domain = "fern.garden";
      };
    };
  };
}
