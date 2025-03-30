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
  cfg = config.${namespace}.services.tailscale-exit-node;
in
{
  options.${namespace}.services.tailscale-exit-node = with types; {
    enable = mkBoolOpt false "Enable a tailscale exit node";
  };

  config = mkIf cfg.enable {
    age.secrets = {
      tailscale.rekeyFile = (inputs.self + "/secrets/services/tailscale.age");
      protonvpn-tailscale.rekeyFile = (inputs.self + "/secrets/services/protonvpn-tailscale.age");
    };

    virtualisation.oci-containers.containers = {
      tailscale-exit-node = {
        image = "tailscale/tailscale:latest";
        dependsOn = [ "gluetun-tailscale" ];
        extraOptions = [
          "--device=/dev/net/tun"
          "--cap-add=NET_ADMIN"
          "--cap-add=NET_RAW"
          "--network=container:gluetun-tailscale"
          "--pull=newer"
        ];
        environmentFiles = [ config.age.secrets.tailscale.path ];
        environment = {
          TS_EXTRA_ARGS = "--advertise-exit-node";
          TS_STATE_DIR = "/var/lib/tailscale";
          TS_HOSTNAME = "nightheron";
        };
        volumes = [
          "tailscale-exit-node:/var/lib/tailscale"
        ];
      };

      gluetun-tailscale = {
        image = "qmcgaw/gluetun:latest";
        extraOptions = [
          "--device=/dev/net/tun"
          "--cap-add=NET_ADMIN"
          "--pull=newer"
        ];
        environmentFiles = [ config.age.secrets.protonvpn-tailscale.path ];
        environment = {
          VPN_SERVICE_PROVIDER = "protonvpn";
          VPN_TYPE = "wireguard";
        };
      };
    };
  };
}
