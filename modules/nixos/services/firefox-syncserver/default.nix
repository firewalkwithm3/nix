{
  inputs,
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.firefox-syncserver;
in
{
  options.${namespace}.services.firefox-syncserver = with types; {
    enable = mkBoolOpt false "Enable firefox-syncserver";
    port = mkOpt port 5002 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.firefox-syncserver.rekeyFile = (inputs.self + "/secrets/services/firefox-syncserver.age");

    services.mysql.package = pkgs.mariadb;

    services.firefox-syncserver = {
      enable = true;
      secrets = config.age.secrets.firefox-syncserver.path;
      settings.port = cfg.port;
      singleNode = {
        enable = true;
        hostname = "localhost";
        url = "http://localhost:${toString cfg.port}";
      };
    };
    ${namespace}.services.caddy.services.firefox-syncserver = {
      port = cfg.port;
      subdomain = "fx-sync";
      domain = "ferngarden.net";
    };
  };
}
