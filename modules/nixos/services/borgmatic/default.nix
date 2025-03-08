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

    services.borgmatic = {
      enable = true;
      configurations = {
        "forest" = {
          exclude_patterns = [
            "/var/lib/audiobookshelf/config/absdatabase.sqlite"
            "/var/lib/bazarr/db/bazarr.db"
            "/var/lib/calibre-server/users.sqlite"
            "/var/lib/calibre-web/app.db"
            "/var/lib/calibre-web/gdrive.db"
            "/var/lib/containers/storage/volumes/hass/_data/zigbee.db*"
            "/var/lib/containers/storage/volumes/hass/_data/home-assistant_v2.db*"
            "/var/lib/containers/storage/volumes/wallos-db/_data/wallos.db"
            "/var/lib/jellyfin/data/jellyfin.db*"
            "/var/lib/jellyfin/data/library.db*"
            "/var/lib/jellyfin/data/playback_reporting.db"
            "/var/lib/jellyseerr/db/db.sqlite3*"
            "/var/lib/lidarr/.config/Lidarr/lidarr.db*"
            "/var/lib/lidarr/.config/Lidarr/logs.db*"
            "/var/lib/navidrome/navidrome.db*"
            "/var/lib/nixos-containers/readarr-audio/var/lib/readarr/readarr.db*"
            "/var/lib/nixos-containers/readarr-audio/var/lib/readarr/logs.db*"
            "/var/lib/nixos-containers/readarr-ebook/var/lib/readarr/readarr.db*"
            "/var/lib/nixos-containers/readarr-ebook/var/lib/readarr/logs.db*"
            "/var/lib/prowlarr/prowlarr.db*"
            "/var/lib/prowlarr/logs.db*"
            "/var/lib/radarr/.config/Radarr/radarr.db*"
            "/var/lib/radarr/.config/Radarr/logs.db*"
            "/var/lib/sonarr/.config/NzbDrone/sonarr.db*"
            "/var/lib/sonarr/.config/NzbDrone/logs.db*"
          ];
          source_directories = [
            "/var/lib/audiobookshelf"
            "/var/lib/authentik"
            "/var/lib/bazarr"
            "/var/lib/bitwarden_rs"
            "/var/lib/caddy"
            "/var/lib/calibre-server"
            "/var/lib/calibre-web"
            "/var/lib/containers/storage/volumes/appdaemon-certs"
            "/var/lib/containers/storage/volumes/appdaemon-config"
            "/var/lib/containers/storage/volumes/hass"
            "/var/lib/containers/storage/volumes/priviblur"
            "/var/lib/containers/storage/volumes/wallos-db"
            "/var/lib/containers/storage/volumes/wallos-logos"
            "/var/lib/containers/storage/volumes/qbittorrent-config"
            "/var/lib/crowdsec"
            "/var/lib/esphome"
            "/var/lib/forgejo"
            "/var/lib/immich"
            "/var/lib/invidious"
            "/var/lib/jellyfin"
            "/var/lib/jellyseerr"
            "/var/lib/lidarr"
            "/var/lib/matrix-synapse"
            "/var/lib/minecraft"
            "/var/lib/navidrome"
            "/var/lib/nextcloud"
            "/var/lib/nixos-containers/readarr-audio/var/lib/readarr"
            "/var/lib/nixos-containers/readarr-ebook/var/lib/readarr"
            "/var/lib/pixelfed"
            "/var/lib/prowlarr"
            "/var/lib/radarr"
            "/var/lib/sonarr"
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
              name = "navidrome";
              path = "/var/lib/navidrome/navidrome.db";
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
          ];
          repositories = [
            {
              label = "borgbase";
              path = "ssh://b3w98w7t@b3w98w7t.repo.borgbase.com/./repo";
            }
            {
              label = "onedrive";
              path = "/mnt/onedrive/Backups/forest";
            }
          ];
          compression = "lz4";
          archive_name_format = "backup-{now}";
          keep_daily = 7;
          keep_weekly = 4;
          keep_monthly = 2;
          skip_actions = [ "check" ];
          encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.age.secrets.borgmatic.path}";
          ssh_command = "ssh -i /home/fern/.ssh/borgmatic";
        };
      };
    };
  };
}
