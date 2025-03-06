{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.bazarr;
in
{
  options.${namespace}.services.bazarr = with types; {
    enable = mkBoolOpt false "Enable Bazarr";
    port = mkOpt port 0 "Port to run on";
  };

  config = mkIf cfg.enable {
    services.bazarr = {
      enable = true;
      listenPort = cfg.port;
      group = "media";
    };

    ${namespace}.services.caddy.services.bazarr = {
      port = cfg.port;
      subdomain = "bazarr";
      domain = "ferngarden.net";
    };
  };
}
