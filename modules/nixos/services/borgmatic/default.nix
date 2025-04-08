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
  cfg = config.${namespace}.services.borgmatic;
in
{
  options.${namespace}.services.borgmatic = with types; {
    enable = mkBoolOpt false "Enable automatic borg backups";
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
          exclude_patterns = [
            "*.sqlite*"
            "*.db*"
          ];
          source_directories = [
            "/var/lib/audiobookshelf"
            "/var/lib/authentik"
            "/var/lib/bazarr"
            "/var/lib/caddy"
            "/var/lib/calibre-server"
            "/var/lib/calibre-web"
            "/var/lib/containers/storage/volumes/appdaemon-certs"
            "/var/lib/containers/storage/volumes/appdaemon-config"
            "/var/lib/containers/storage/volumes/hass"
            "/var/lib/containers/storage/volumes/pinchflat-config"
            "/var/lib/containers/storage/volumes/priviblur"
            "/var/lib/containers/storage/volumes/qbittorrent-config"
            "/var/lib/containers/storage/volumes/seedboxapi"
            "/var/lib/containers/storage/volumes/wallos-db"
            "/var/lib/containers/storage/volumes/wallos-logos"
            "/var/lib/crowdsec"
            "/var/lib/dhparams"
            "/var/lib/dovecot"
            "/var/lib/esphome"
            "/var/lib/forgejo"
            "/var/lib/immich"
            "/var/lib/invidious"
            "/var/lib/jellyfin"
            "/var/lib/jellyseerr"
            "/var/lib/lidarr"
            "/var/lib/matrix-synapse"
            "/var/lib/minecraft"
            "/var/lib/mosquitto"
            "/var/lib/navidrome"
            "/var/lib/nixos-containers/nextcloud/var/lib/nextcloud"
            "/var/lib/nixos-containers/pixelfed/var/lib/pixelfed"
            "/var/lib/nixos-containers/readarr-audio/var/lib/readarr"
            "/var/lib/nixos-containers/readarr-ebook/var/lib/readarr"
            "/var/lib/ntfy-sh"
            "/var/lib/opendkim"
            "/var/lib/postfix"
            "/var/lib/prowlarr"
            "/var/lib/radarr"
            "/var/lib/rspamd"
            "/var/lib/sonarr"
            "/var/lib/vaultwarden"
            "/var/lib/zigbee2mqtt"
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
          sqlite_databases = [
            {
              name = "audiobookshelf";
              path = "/var/lib/audiobookshelf/config/absdatabase.sqlite";
            }
            {
              name = "bazarr";
              path = "/var/lib/bazarr/db/bazarr.db";
            }
            {
              name = "calibre-server";
              path = "/var/lib/calibre-server/users.sqlite";
            }
            {
              name = "calibre-web-app";
              path = "/var/lib/calibre-web/app.db";
            }
            {
              name = "calibre-web-gdrive";
              path = "/var/lib/calibre-web/gdrive.db";
            }
            {
              name = "homeassistant-zigbee";
              path = "/var/lib/containers/storage/volumes/hass/_data/zigbee.db";
            }
            {
              name = "homeassistant";
              path = "/var/lib/containers/storage/volumes/hass/_data/home-assistant_v2.db";
            }
            {
              name = "memos";
              path = "/var/lib/containers/storage/volumes/memos/_data/memos_prod.db";
            }
            {
              name = "lurker";
              path = "/lurker.db";
            }
            {
              name = "wallos";
              path = "/var/lib/containers/storage/volumes/wallos-db/_data/wallos.db";
            }
            {
              name = "jellyfin";
              path = "/var/lib/jellyfin/data/jellyfin.db";
            }
            {
              name = "jellyfin-library";
              path = "/var/lib/jellyfin/data/library.db";
            }
            {
              name = "jellyfin-playback_reporting";
              path = "/var/lib/jellyfin/data/playback_reporting.db";
            }
            {
              name = "jellyseerr";
              path = "/var/lib/jellyseerr/db/db.sqlite3";
            }
            {
              name = "lidarr";
              path = "/var/lib/lidarr/.config/Lidarr/lidarr.db";
            }
            {
              name = "lidarr-logs";
              path = "/var/lib/lidarr/.config/Lidarr/logs.db";
            }
            {
              name = "mosquitto";
              path = "/var/lib/mosquitto/mosquitto.db";
            }
            {
              name = "navidrome";
              path = "/var/lib/navidrome/navidrome.db";
            }
            {
              name = "ntfy-sh-cache-file";
              path = "/var/lib/ntfy-sh/cache-file.db";
            }
            {
              name = "ntfy-sh-user";
              path = "/var/lib/ntfy-sh/user.db";
            }
            {
              name = "readarr-audio";
              path = "/var/lib/nixos-containers/readarr-audio/var/lib/readarr/readarr.db";
            }
            {
              name = "readarr-audio-logs";
              path = "/var/lib/nixos-containers/readarr-audio/var/lib/readarr/logs.db";
            }
            {
              name = "readarr-ebook";
              path = "/var/lib/nixos-containers/readarr-ebook/var/lib/readarr/readarr.db";
            }
            {
              name = "readarr-ebook-logs";
              path = "/var/lib/nixos-containers/readarr-ebook/var/lib/readarr/logs.db";
            }
            {
              name = "postfix-aliases";
              path = "/var/lib/postfix/conf/aliases.db";
            }
            {
              name = "postfix-denied_recipients";
              path = "/var/lib/postfix/conf/denied_recipients.db";
            }
            {
              name = "postfix-regex_vaccounts";
              path = "/var/lib/postfix/conf/regex_vaccounts.db";
            }
            {
              name = "postfix-regex_valias";
              path = "/var/lib/postfix/conf/regex_valias.db";
            }
            {
              name = "postfix-reject_recipients";
              path = "/var/lib/postfix/conf/reject_recipients.db";
            }
            {
              name = "postfix-reject_senders";
              path = "/var/lib/postfix/conf/reject_senders.db";
            }
            {
              name = "postfix-vaccounts";
              path = "/var/lib/postfix/conf/vaccounts.db";
            }
            {
              name = "postfix-valias";
              path = "/var/lib/postfix/conf/valias.db";
            }
            {
              name = "postfix-virtual";
              path = "/var/lib/postfix/conf/virtual.db";
            }
            {
              name = "prowlarr";
              path = "/var/lib/prowlarr/prowlarr.db";
            }
            {
              name = "prowlarr-logs";
              path = "/var/lib/prowlarr/logs.db";
            }
            {
              name = "radarr";
              path = "/var/lib/radarr/.config/Radarr/radarr.db";
            }
            {
              name = "radarr-logs";
              path = "/var/lib/radarr/.config/Radarr/logs.db";
            }
            {
              name = "sonarr";
              path = "/var/lib/sonarr/.config/NzbDrone/sonarr.db";
            }
            {
              name = "sonarr-logs";
              path = "/var/lib/sonarr/.config/NzbDrone/logs.db";
            }
            {
              name = "zigbee2mqtt";
              path = "/var/lib/zigbee2mqtt/database.db";
            }
          ];
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
          compression = "lz4";
          archive_name_format = "backup-{now}";
          keep_daily = 7;
          keep_weekly = 4;
          keep_monthly = 2;
          skip_actions = [ "check" ];
          # encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.borgmatic.path}";
          encryption_passphrase = "{credential file ${config.age.secrets.borgmatic.path}}";
          ssh_command = "ssh -i /etc/ssh/ssh_host_ed25519_key";
        };
      };
    };
  };
}
