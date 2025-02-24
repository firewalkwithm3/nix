{ config, ... }:
{
  age.secrets.gluetun-config.rekeyFile = ../../../secrets/services/gluetun-config.age;
  age.secrets.protonvpn.rekeyFile = ../../../secrets/services/protonvpn.age;

  virtualisation.oci-containers = {
    containers.gluetun = {
      image = "qmcgaw/gluetun:latest";
      extraOptions = [
        "--device=/dev/net/tun"
        "--cap-add=NET_ADMIN"
        "--pull=newer"
      ];
      ports = [ "5001:5001" ];
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
}
