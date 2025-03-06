{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.vaultwarden;
in
{
  options.${namespace}.services.vaultwarden = with types; {
    enable = mkBoolOpt false "Enable vaultwarden";
    port = mkOpt port 8087 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.vaultwarden = {
      rekeyFile = ../../../../secrets/services/vaultwarden.age;
      owner = "vaultwarden";
      group = "vaultwarden";
    };

    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      config = {
        DOMAIN = "https://vault.ferngarden.net";
        WEBSOCKET_ENABLED = true;
        SIGNUPS_ALLOWED = false;
        INVITATIONS_ALLOWED = false;
        DATABASE_URL = "postgresql:///vaultwarden";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = cfg.port;
      };
      environmentFile = config.age.secrets.vaultwarden.path;
    };

    ${namespace}.services.caddy.services.vaultwarden = {
      port = cfg.port;
      subdomain = "vault";
      domain = "ferngarden.net";
    };
  };
}
