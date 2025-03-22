{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.readarr-audiobooks;
in
{
  options.${namespace}.services.readarr-audiobooks = with types; {
    enable = mkBoolOpt false "Enable readarr-audiobooks - audiobook fetcher & organiser";
    port = mkOpt port 8787 "Port to run on";
    host = mkStrOpt "192.168.100.21" "IP to bind to";
  };

  config = mkIf cfg.enable {
    containers.readarr-audio = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.20";
      localAddress = cfg.host;
      bindMounts = {
        "volume2" = {
          hostPath = "/mnt/volume2";
          mountPoint = "/mnt/volume2";
          isReadOnly = false;
        };
      };

      config =
        { lib, ... }:
        {
          users.groups.media = {
            gid = 1800;
          };

          services.readarr = {
            enable = true;
            group = "media";
          };

          system.stateVersion = "24.11";

          networking = {
            firewall = {
              enable = true;
              allowedTCPPorts = [ cfg.port ];
            };
            useHostResolvConf = lib.mkForce false;
          };

          services.resolved.enable = true;
        };
    };

    ${namespace}.services.caddy.services.readarr-audiobooks = {
      port = config.${namespace}.services.authentik.port;
      subdomain = "readarr-audiobooks";
      domain = "ferngarden.net";
    };
  };
}
