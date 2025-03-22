{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.immich;
in
{
  options.${namespace}.services.immich = with types; {
    enable = mkBoolOpt false "Enable immich - cloud photo storage";
    port = mkOpt port 3001 "Port to run on";
  };

  config = mkIf cfg.enable {
    services.immich = {
      enable = true;
      redis.enable = true;
      machine-learning.enable = true;
      host = "127.0.0.1";
      port = cfg.port;
    };

    ${namespace}.services.caddy.services.immich = {
      port = cfg.port;
      subdomain = "photos";
      domain = "ferngarden.net";
    };
  };
}
