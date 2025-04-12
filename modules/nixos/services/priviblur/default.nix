{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.priviblur;
  dataDir = "${podmanVolumeDir}/priviblur";
in
{
  options.${namespace}.services.priviblur = with types; {
    enable = mkBoolOpt false "Enable priviblur - private tumblr frontend";
    port = mkOpt port 8084 "Port to run on";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      priviblur = {
        image = "quay.io/syeopite/priviblur:latest";
        ports = [ "${toString cfg.port}:8000" ];
        volumes = [
          "priviblur:/priviblur"
        ];
        extraOptions = [ "--pull=newer" ];
      };
    };

    ${namespace} = {
      backups.modules.priviblur = {
        directories = [ dataDir ];
      };

      services.caddy.services.priviblur = {
        port = config.${namespace}.services.authentik.port;
        subdomain = "priviblur";
        domain = "ferngarden.net";
      };
    };
  };
}
