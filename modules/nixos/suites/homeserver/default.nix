{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.homeserver;
in
{
  options.${namespace}.suites.homeserver = with types; {
    enable = mkBoolOpt false "Enable home server suite";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      filesystems.rclone = enabled;
      networking.containers = enabled;
      nixos.timers = enabled;
      pam.rssh = enabled;
      user = {
        groups.media = enabled;
        passwdless-sudo = enabled;
      };

      services = {
        audiobookshelf = enabled;
        bazarr = enabled;
        borgmatic = enabled;
        caddy = enabled;
        calibre = enabled;
        forgejo = enabled;
        home-assistant = enabled;
        immich = enabled;
        jellyfin = enabled;
        jellyseerr = enabled;
        lidarr = enabled;
        mailserver = enabled;
        matrix-synapse = enabled;
        memos = enabled;
        minecraft = enabled;
        miniflux = enabled;
        navidrome = enabled;
        nextcloud = enabled;
        ntfy = enabled;
        pinchflat = enabled;
        pixelfed = enabled;
        postgres = enabled;
        priviblur = enabled;
        prowlarr = enabled;
        qbittorrent = enabled;
        radarr = enabled;
        readarr-audiobooks = enabled;
        readarr-ebooks = enabled;
        sonarr = enabled;
        vaultwarden = enabled;
        wallos = enabled;
      };
    };
  };
}
