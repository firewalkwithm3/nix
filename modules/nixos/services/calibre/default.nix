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
  web.dataDir = "/var/lib/${config.services.calibre-web.dataDir}";
  server.dataDir = "/var/lib/calibre-server";
in
{
  options.${namespace}.services.calibre = with types; {
    enable = mkBoolOpt false "Enable calibre-server & calibre-web - ebook manager";
    web.port = mkOpt port 8090 "Port for calibre-web to run on";
    server.port = mkOpt port 8089 "Port for calibre-server to run on";
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
      listen.port = cfg.web.port;
      options.calibreLibrary = "/mnt/volume2/media/calibre/library";
    };

    services.calibre-server = {
      enable = true;
      host = "0.0.0.0";
      port = cfg.server.port;
      group = "media";
      auth = {
        enable = true;
        mode = "auto";
        userDb = "/var/lib/calibre-server/users.sqlite";
      };
      libraries = [ "/mnt/volume2/media/calibre/library" ];
    };

    ${namespace} = {
      backups.modules.calibre = {
        directories = [
          web.dataDir
          server.dataDir
        ];
        databases = [
          "${web.dataDir}/app.db"
          "${web.dataDir}/gdrive.db"
          config.services.calibre-server.auth.userDb
        ];
      };

      services.caddy.services.calibre = {
        port = cfg.web.port;
        subdomain = "books";
        domain = "fern.garden";
      };
    };
  };
}
