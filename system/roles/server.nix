{
  imports = [
    ./common.nix

    # system config
    ../modules/networking/server.nix
    ../modules/users/server.nix

    # services
    ../modules/services/matrix.nix
    ../modules/services/postgresql.nix
    ../modules/services/pixelfed.nix
    ../modules/services/jellyseerr.nix
    ../modules/services/nextcloud.nix
    #../modules/services/lurker.nix
    ../modules/services/navidrome.nix
    ../modules/services/wallos.nix
    ../modules/services/immich.nix
    ../modules/services/miniflux.nix
    ../modules/services/radarr.nix
    ../modules/services/prowlarr.nix
    ../modules/services/crowdsec.nix
    ../modules/services/authentik.nix
    ../modules/services/borgmatic.nix
    ../modules/services/priviblur.nix
    ../modules/services/lidarr.nix
    ../modules/services/bazarr.nix
    ../modules/services/sonarr.nix
    ../modules/services/vaultwarden.nix
    ../modules/services/gluetun.nix
    ../modules/services/invidious.nix
    ../modules/services/calibre.nix
    ../modules/services/qbittorrent.nix
    ../modules/services/forgejo.nix
    ../modules/services/esphome.nix
    ../modules/services/minecraft.nix
    ../modules/services/readarr-audio.nix
    ../modules/services/audiobookshelf.nix
    ../modules/services/caddy.nix
    ../modules/services/memos.nix
    ../modules/services/readarr-ebook.nix
    ../modules/services/homeassistant.nix
    ../modules/services/jellyfin.nix
    ../modules/services/ntfy.nix
  ];

  # Permit insecure packages
  nixpkgs.config.permittedInsecurePackages = [
    # sonarr
    "aspnetcore-runtime-wrapped-6.0.36"
    "aspnetcore-runtime-6.0.36"
    "dotnet-sdk-wrapped-6.0.428"
    "dotnet-sdk-6.0.428"
  ];
}
