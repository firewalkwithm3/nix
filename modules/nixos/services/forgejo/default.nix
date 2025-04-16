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
  cfg = config.${namespace}.services.forgejo;
in
{
  options.${namespace}.services.forgejo = with types; {
    enable = mkBoolOpt false "Enable forgejo - git frontend";
    port = mkOpt port 3000 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.forgejo.rekeyFile = (inputs.self + "/secrets/services/forgejo.age");

    services.forgejo = {
      enable = true;
      database = {
        type = "postgres";
        socket = "/var/run/postgresql";
      };
      settings.DEFAULT = {
        APP_NAME = "Fern's Git Server";
        RUN_MODE = "prod";
      };
      settings.server = {
        DOMAIN = "git.fern.garden";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = cfg.port;
        ROOT_URL = "https://git.fern.garden";
      };
      settings.mailer = {
        ENABLED = true;
        FROM = "admin@ferngarden.net";
        SMTP_ADDR = "mail.ferngarden.net";
        SMTP_PORT = 465;
        USER = "admin@ferngarden.net";
      };
      secrets.mailer.PASSWD = config.age.secrets.forgejo.path;
      settings.service.DISABLE_REGISTRATION = true;
    };

    ${namespace} = {
      backups.modules.forgejo = {
        directories = [ config.services.forgejo.stateDir ];
      };

      services.postgres.databases = [ "forgejo" ];

      services.caddy.services.forgejo = {
        port = cfg.port;
        subdomain = "git";
        domain = "fern.garden";
      };
    };
  };
}
