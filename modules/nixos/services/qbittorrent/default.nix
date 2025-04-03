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
    enable = mkBoolOpt false "Enable qbittorrent - torrent client";
    port = mkOpt port 5001 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets = {
      qsticky.rekeyFile = (inputs.self + "/secrets/services/qsticky.age");
      mam.rekeyFile = (inputs.self + "/secrets/services/mam.age");
      gluetun-qbittorrent.rekeyFile = (inputs.self + "/secrets/services/gluetun-qbittorrent.age");
      protonvpn-qbittorrent.rekeyFile = (inputs.self + "/secrets/services/protonvpn-qbittorrent.age");
    };

    virtualisation.oci-containers.containers = {
      qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        dependsOn = [ "gluetun-qbittorrent" ];
        extraOptions = [
          "--network=container:gluetun-qbittorrent"
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

      gluetun-qbittorrent = {
        image = "qmcgaw/gluetun:latest";
        extraOptions = [
          "--device=/dev/net/tun"
          "--cap-add=NET_ADMIN"
          "--pull=newer"
        ];
        ports = [ "${toString cfg.port}:${toString cfg.port}" ];
        volumes = [ "${config.age.secrets.gluetun-qbittorrent.path}:/gluetun/auth/config.toml" ];
        environmentFiles = [ config.age.secrets.protonvpn-qbittorrent.path ];
        environment = {
          VPN_SERVICE_PROVIDER = "protonvpn";
          VPN_TYPE = "wireguard";
          VPN_PORT_FORWARDING = "on";
          GLUETUN_HTTP_CONTROL_SERVER_ENABLE = "on";
        };
      };

      qsticky = {
        image = "ghcr.io/monstermuffin/qsticky:latest";
        environmentFiles = [ config.age.secrets.qsticky.path ];
        environment = {
          QBITTORRENT_HOST = "gluetun-qbittorrent";
          QBITTORRENT_HTTPS = "false";
          QBITTORRENT_PORT = "${toString cfg.port}";
          GLUETUN_HOST = "gluetun-qbittorrent";
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
        dependsOn = [ "gluetun-qbittorrent" ];
        extraOptions = [
          "--network=container:gluetun-qbittorrent"
          "--pull=newer"
        ];
        environment = {
          DEBUG = "1";
          interval = "60";
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
