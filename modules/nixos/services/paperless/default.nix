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
  cfg = config.${namespace}.services.paperless;
in
{
  options.${namespace}.services.paperless = with types; {
    enable = mkBoolOpt false "Enable paperless - document management server";
    port = mkOpt port 28981 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.paperless.rekeyFile = inputs.self + "/secrets/services/paperless.age";

    services.paperless = {
      enable = true;
      passwordFile = config.age.secrets.paperless.path;
      port = cfg.port;
      address = "127.0.0.1";
      settings.PAPERLESS_DBHOST = "/var/run/postgresql";
    };

    ${namespace}.services.caddy.services.paperless = {
      port = cfg.port;
      subdomain = "paperless";
      domain = "ferngarden.net";
    };
  };
}
