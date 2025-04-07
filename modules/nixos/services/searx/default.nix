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
  cfg = config.${namespace}.services.searx;
in
{
  options.${namespace}.services.searx = with types; {
    enable = mkBoolOpt false "Enable searx - meta search engine";
    port = mkOpt port 8086 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.searx.rekeyFile = (inputs.self + "/secrets/services/searx.age");

    services.searx = {
      enable = true;
      environmentFile = config.age.secrets.searx.path;
      settings = {
        server = {
          port = cfg.port;
          bind_address = "127.0.0.1";
          secret_key = "@SEARX_SECRET_KEY@";
        };
      };
    };

    ${namespace}.services.caddy.services.searx = {
      port = cfg.port;
      subdomain = "search";
      domain = "ferngarden.net";
    };
  };
}
