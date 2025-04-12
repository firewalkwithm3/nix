{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.home-assistant;
in
{
  options.${namespace}.services.home-assistant = with types; {
    enable = mkBoolOpt false "Enable home assistant - home automation software";
    port = mkOpt port 8123 "Port to run on";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    virtualisation.oci-containers = {
      containers.homeassistant = {
        volumes = [
          "hass:/config"
        ];
        environment.TZ = "Europe/Berlin";
        image = "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [
          "--network=host"
          "--device=/dev/ttyUSB0:/dev/ttyUSB0"
          "--pull=newer"
        ];
      };

      containers.appdaemon = {
        volumes = [
          "appdaemon-config:/conf"
          "appdaemon-certs:/certs"
        ];
        image = "acockburn/appdaemon:latest";
        extraOptions = [
          "--network=host"
          "--pull=newer"
        ];
      };
    };

    ${namespace} = {
      backups.modules.homeassistant = {
        directories = [
          "${podmanVolumeDir}/hass"
          "${podmanVolumeDir}/appdaemon-config"
          "${podmanVolumeDir}/appdaemon-certs"
        ];
        databases = [
          {
            name = "homeassistant";
            path = "${podmanVolumeDir}/hass/_data/home-assistant_v2.db";
          }
        ];
      };

      services.caddy.services.home-assistant = {
        port = cfg.port;
        subdomain = "home";
        domain = "fern.garden";
      };
    };
  };
}
