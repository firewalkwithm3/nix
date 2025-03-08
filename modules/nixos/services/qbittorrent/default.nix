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
  cfg = config.${namespace}.services.qbittorrent;
in
{
  options.${namespace}.services.qbittorrent = with types; {
    enable = mkBoolOpt false "Enable qbittorrent";
    port = mkOpt port 5001 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.qsticky.rekeyFile = (inputs.self + "/secrets/services/qsticky.age");
    age.secrets.mam.rekeyFile = (inputs.self + "/secrets/services/mam.age");

    virtualisation.oci-containers.containers = {
      qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        dependsOn = [ "gluetun" ];
        extraOptions = [
          "--network=container:gluetun"
          "--pull=newer"
        ];
        environment = {
          PUID = "1000";
          PGID = "1800";
          TZ = "Australia/Perth";
          WEBUI_PORT = "${toString cfg.port}";
        };
        volumes = [
          "qbittorrent-config:/config"
          "qbittorrent-downloads:/downloads"
          "/mnt/volume1:/mnt/volume1"
          "/mnt/volume2:/mnt/volume2"
          "/mnt/volume3:/mnt/volume3"
        ];
      };

      qsticky = {
        image = "ghcr.io/monstermuffin/qsticky:latest";
        environmentFiles = [ config.age.secrets.qsticky.path ];
        environment = {
          QBITTORRENT_HOST = "gluetun";
          QBITTORRENT_HTTPS = "false";
          QBITTORRENT_PORT = "${toString cfg.port}";
          GLUETUN_HOST = "gluetun";
          GLUETUN_PORT = "8000";
          GLUETUN_AUTH_TYPE = "apikey";
          LOG_LEVEL = "INFO";
        };
        extraOptions = [ "--pull=newer" ];
      };

      seedboxapi = {
        image = "myanonamouse/seedboxapi";
        environmentFiles = [ config.age.secrets.mam.path ];
        volumes = [ "seedboxapi:/config" ];
        dependsOn = [ "gluetun" ];
        extraOptions = [
          "--network=container:gluetun"
          "--pull=newer"
        ];
        environment = {
          DEBUG = "1";
          interval = "1";
        };
      };
    };

    ${namespace}.services.caddy.services.qbittorrent = {
      port = cfg.port;
      subdomain = "qbittorrent";
      domain = "ferngarden.net";
    };
  };
}
