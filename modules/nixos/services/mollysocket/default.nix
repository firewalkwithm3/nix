{
  inputs,
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.mollysocket;
in
{
  options.${namespace}.services.mollysocket = with types; {
    enable = mkBoolOpt false "Enable mollysocket - Signal notifications via UnifiedPush";
    port = mkOpt port 8020 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.mollysocket.rekeyFile = (inputs.self + "/services/mollysocket.age");

    services.mollysocket = {
      enable = true;
      environmentFile = config.age.secrets.mollysocket.path;
      settings.allowed_endpoints = [ "https://ntfy.fern.garden" ];
    };

    ${namespace}.services.caddy.services.mollysocket = {
      port = cfg.port;
      subdomain = "mollysocket";
      domain = "ferngarden.net";
    };
  };
}
