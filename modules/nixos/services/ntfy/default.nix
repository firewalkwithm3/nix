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
  dataDir = "/var/lib/ntfy-sh";
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

    ${namespace} = {
      backups.modules.ntfy = {
        directories = [ dataDir ];
        databases = [
          {
            name = "ntfy-cache";
            path = "${dataDir}/cache-file.db";
          }
          {
            name = "ntfy-users";
            path = "${dataDir}/user.db";
          }
        ];
      };
      services.caddy.services.ntfy = {
        port = cfg.port;
        subdomain = "ntfy";
        domain = "ferngarden.net";
      };
    };
  };
}
