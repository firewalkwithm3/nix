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

  hostName = config.networking.hostName;

  module = {
    options = with types; {
      databases = mkOpt (listOf (submodule {
        options = with types; {
          path = mkStrOpt "" "Path to sqlite database";
          name = mkStrOpt "" "Name of sqlite database";
        };
      })) [ ] "sqlite databases to back up";
      directories = mkOpt (listOf str) [ ] "Directories to back up";
    };
  };

  mkBackups =
    modules:
    let
      values = attrValues modules;
    in
    rec {
      source_directories = concatLists (map (module: module.directories) values);
      sqlite_databases = concatLists (map (module: module.databases) values);
      exclude_patterns = attrsets.catAttrs "path" sqlite_databases;
    };

in
{
  options.${namespace}.backups = with types; {
    enable = mkBoolOpt false "Enable automatic borg backups";
    modules = mkOpt (attrsOf (submodule module)) { } "The modules to back up";
    targetHost = mkStrOpt "" "Target to backup to";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.targetHost != "";
        message = "Please provide the target backup host";
      }
    ];

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
        "${hostName}" = {
          compression = "lz4";
          archive_name_format = "backup-{now}";
          keep_daily = 7;
          keep_weekly = 4;
          keep_monthly = 2;
          skip_actions = [ "check" ];
          encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.borgmatic.path}";
          ssh_command = "ssh -i /etc/ssh/ssh_host_ed25519_key";

          repositories = mkMerge [
            (mkIf config.${namespace}.filesystems.rclone.enable [
              {
                label = "onedrive";
                path = "/mnt/onedrive/Backups/${hostName}";
              }
            ])

            [
              {
                label = "${cfg.targetHost}";
                path = "ssh://borg@${cfg.targetHost}/./${hostName}";
              }
              {
                label = "local";
                path = "/var/lib/backups/${hostName}";
              }
            ]
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
