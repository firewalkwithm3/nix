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
  cfg = config.${namespace}.services.gluetun;
in
{
  options.${namespace}.services.gluetun = with types; {
    enable =
      mkBoolOpt config.${namespace}.services.qbittorrent.enable
        "Enable gluetun - VPN client in a container";
    port = mkOpt port 5001 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.gluetun-config.rekeyFile = (inputs.self + "/secrets/services/gluetun-config.age");
    age.secrets.protonvpn.rekeyFile = (inputs.self + "/secrets/services/protonvpn.age");

    virtualisation.oci-containers = {
      containers.gluetun = {
        image = "qmcgaw/gluetun:latest";
        extraOptions = [
          "--device=/dev/net/tun"
          "--cap-add=NET_ADMIN"
          "--pull=newer"
        ];
        ports = [ "${toString cfg.port}:${toString cfg.port}" ];
        volumes = [ "${config.age.secrets.gluetun-config.path}:/gluetun/auth/config.toml" ];
        environmentFiles = [ config.age.secrets.protonvpn.path ];
        environment = {
          VPN_SERVICE_PROVIDER = "protonvpn";
          VPN_TYPE = "wireguard";
          VPN_PORT_FORWARDING = "on";
          GLUETUN_HTTP_CONTROL_SERVER_ENABLE = "on";
        };
      };
    };

  };
}
