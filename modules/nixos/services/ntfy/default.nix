{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.ntfy;
in
{
  options.${namespace}.services.ntfy = with types; {
    enable = mkBoolOpt false "Enable ntfy - notification service";
    port = mkOpt port 2586 "Port to run on";
  };

  config = mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings.base-url = "https://ntfy.ferngarden.net";
      settings.auth-default-access = "deny-all";
    };

    ${namespace}.services.caddy.services.ntfy = {
      port = cfg.port;
      subdomain = "ntfy";
      domain = "ferngarden.net";
    };
  };
}
