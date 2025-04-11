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
  cfg = config.${namespace}.backups;

  module = {
    options = with types; {
      databases = mkOpt (listOf str) [ ] "sqlite databases to back up";
      directories = mkOpt (listOf str) [ ] "Directories to back up";
    };
  };

  mkBackups =
    modules:
    let
      values = attrValues modules;
    in
    {
      source_directories = concatLists (map (module: module.directories) values);
      sqlite_databases = concatLists (map (module: module.databases) values);
    };

in
{
  options.${namespace}.backups = with types; {
    enable = mkBoolOpt false "Enable automatic borg backups";
    modules = mkOpt (attrsOf (submodule module)) { } "The modules to back up";
  };

  config = mkIf cfg.enable {
    age.secrets.borgmatic.rekeyFile = (inputs.self + "/secrets/services/borgmatic.age");

    systemd.services.borgmatic.path = [ pkgs.sqlite ];

    systemd.tmpfiles.settings."10-borgmatic" = {
      "/var/lib/backups".d = {
        mode = "0775";
        user = "root";
        group = "root";
      };
    };

    services.borgmatic = {
      enable = true;
      configurations = {
        "spoonbill" = {
          compression = "lz4";
          archive_name_format = "backup-{now}";
          keep_daily = 7;
          keep_weekly = 4;
          keep_monthly = 2;
          skip_actions = [ "check" ];
          encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.borgmatic.path}";
          ssh_command = "ssh -i /etc/ssh/ssh_host_ed25519_key";

          repositories = [
            {
              label = "onedrive";
              path = "/mnt/onedrive/Backups/spoonbill";
            }
            {
              label = "weebill";
              path = "ssh://borg@weebill/./spoonbill";
            }
            {
              label = "local";
              path = "/var/lib/backups/spoonbill";
            }
          ];

          postgresql_databases = [
            {
              name = "all";
              format = "custom";
              username = "postgres";
              pg_dump_command = "${pkgs.postgresql_16}/bin/pg_dump";
              psql_command = "${pkgs.postgresql_16}/bin/psql";
              pg_restore_command = "${pkgs.postgresql_16}/bin/pg_restore";
            }
          ];
        } // mkBackups cfg.modules;
      };
    };
  };
}
