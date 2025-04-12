{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.memos;
in
{
  options.${namespace}.services.memos = with types; {
    enable = mkBoolOpt false "Enable memos - note-taking application";
    port = mkOpt port 5230 "Port to run on";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      memos = {
        image = "neosmemo/memos:latest";
        ports = [ "${toString cfg.port}:${toString cfg.port}" ];
        volumes = [
          "memos:/var/opt/memos"
        ];
        extraOptions = [ "--pull=newer" ];
      };
    };

    ${namespace} = {
      backups.modules.memos = {
        directories = [ "${podmanVolumeDir}/memos" ];
        databases = [ "${podmanVolumeDir}/memos/memos_prod.db" ];
      };

      services.caddy.services.memos = {
        port = cfg.port;
        subdomain = "memos";
        domain = "ferngarden.net";
      };
    };
  };
}
