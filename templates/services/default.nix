{
  options,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.myService;
in
{
  options.${namespace}.services.myService = with types; {
    enable = mkBoolOpt false "Enable myService";
    port = mkOpt port 0 "Port to run on";
  };

  config = mkIf cfg.enable {
    ${namespace}.services.caddy.services.myService = {
      port = cfg.port;
      subdomain = "mySubdomain";
      domain = "myDomain";
    };
  };
}
