{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.wallos;
in
{
  options.${namespace}.services.wallos = with types; {
    enable = mkBoolOpt false "Enable wallos";
    port = mkOpt port 8088 "Port to run on";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers = {
      wallos = {
        image = "bellamy/wallos:latest";
        ports = [ "${toString cfg.port}:80" ];
        volumes = [
          "wallos-db:/var/www/html/db"
          "wallos-logos:/var/www/html/images/uploads/logos"
        ];
        extraOptions = [ "--pull=newer" ];
      };
    };

    ${namespace}.services.caddy.services.wallos = {
      port = config.${namespace}.services.authentik.port;
      subdomain = "subscriptions";
      domain = "ferngarden.net";
    };
  };
}
