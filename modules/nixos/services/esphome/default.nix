{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.esphome;
  dataDir = "/var/lib/esphome";
in
{
  options.${namespace}.services.esphome = with types; {
    enable =
      mkBoolOpt config.${namespace}.services.home-assistant.enable
        "Enable esphome - ESP32 configuration utility";
    port = mkOpt port 6052 "Port to run on";
  };

  config = mkIf cfg.enable {
    services.esphome = {
      enable = true;
      address = "127.0.0.1";
      port = cfg.port;
    };

    ${namespace} = {
      backups.modules.esphome = {
        directories = [ dataDir ];
      };

      services.caddy.services.esphome = {
        port = config.${namespace}.services.authentik.port;
        subdomain = "esphome";
        domain = "ferngarden.net";
      };
    };
  };
}
