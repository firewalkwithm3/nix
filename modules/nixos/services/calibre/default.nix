{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.calibre;
in
{
  options.${namespace}.services.calibre = with types; {
    enable = mkBoolOpt false "Enable Calibre & Calibre Web";
    port = mkOpt port 8090 "Port to run on";
    calibre-server.port = mkOpt port 8089 "Port to access calibre-server";
  };

  config = mkIf cfg.enable {
    services.calibre-web = {
      enable = true;
      package = pkgs.calibre-web.overrideAttrs (
        {
          propagatedBuildInputs ? [ ],
          ...
        }:
        {
          propagatedBuildInputs = propagatedBuildInputs ++ [
            pkgs.python312Packages.python-ldap
            pkgs.python312Packages.flask-simpleldap
          ];
        }
      );
      group = "media";
      listen.ip = "127.0.0.1";
      listen.port = cfg.port;
      options.calibreLibrary = "/mnt/volume2/media/calibre/library";
    };

    services.calibre-server = {
      enable = true;
      host = "0.0.0.0";
      port = cfg.calibre-server.port;
      group = "media";
      auth = {
        enable = true;
        mode = "auto";
        userDb = "/var/lib/calibre-server/users.sqlite";
      };
      libraries = [ "/mnt/volume2/media/calibre/library" ];
    };

    ${namespace}.services.caddy.services.calibre = {
      port = cfg.port;
      subdomain = "books";
      domain = "fern.garden";
    };
  };
}
