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
  cfg = config.${namespace}.services.navidrome;
in
{
  options.${namespace}.services.navidrome = with types; {
    enable = mkBoolOpt false "Enable navidrome - music streaming service";
    port = mkOpt port 4533 "Port to run on";
    musicDir = mkStrOpt "/mnt/volume2/media/beets" "Directory where music files are kept";
  };

  config = mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/issues/151550
    systemd.services.navidrome.serviceConfig.BindReadOnlyPaths = ["/run/systemd/resolve/stub-resolv.conf"];

    services.navidrome = {
      enable = true;
      settings = {
        Address = "127.0.0.1";
        port = cfg.port;
        ReverseProxyWhitelist = "0.0.0.0/0";
        ReverseProxyUserHeader = "X-authentik-username";
        EnableUserEditing = false;
        MusicFolder = cfg.musicDir;
      };
      group = "media";
    };

    age.secrets.explo.rekeyFile = (inputs.self + "/secrets/services/explo.age");

    virtualisation.oci-containers.containers = {
      explo = {
        image = "ghcr.io/lumepart/explo:latest";
        volumes = [
          "${cfg.musicDir}/explo:${cfg.musicDir}/explo"
          "${config.age.secrets.explo.path}:/opt/explo/.env"
        ];
        environment = {
          CRON_SCHEDULE = "0 1 * * 1";
          EXPLO_SYSTEM = "subsonic";
          SYSTEM_URL = "http://127.0.0.1:4533";
          SYSTEM_USERNAME = "fern";
          DOWNLOAD_DIR = "${cfg.musicDir}/explo";
          LISTENBRAINZ_USER = "mtqueerie";
          PERSIST = "false";
          PUID = "1000";
          PGID = "1800";
        };
        extraOptions = [ "--pull=newer" ];
      };
    };

    ${namespace}.services.caddy.services.navidrome = {
      port = config.${namespace}.services.authentik.port;
      subdomain = "music";
      domain = "fern.garden";
    };
  };
}
