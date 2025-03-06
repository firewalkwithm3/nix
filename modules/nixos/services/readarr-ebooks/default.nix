{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.readarr-ebooks;
in
{
  options.${namespace}.services.readarr-ebooks = with types; {
    enable = mkBoolOpt false "Enable readarr-ebooks";
    port = mkOpt port 8787 "Port to run on";
    host = mkStrOpt "192.168.100.22" "IP to bind to";
  };

  config = mkIf cfg.enable {
    networking.nat = {
      forwardPorts = [
        {
          destination = "${cfg.host}:${toString config.${namespace}.services.calibre.calibre-server.port}";
          sourcePort = config.${namespace}.services.calibre.calibre-server.port;
        }
      ];
    };

    containers.readarr-ebook = {
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
        {
          lib,
          ...
        }:
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

    ${namespace}.services.caddy.services.readarr-ebooks = {
      port = cfg.port;
      host = cfg.host;
      subdomain = "readarr-ebooks";
      domain = "ferngarden.net";
    };
  };
}
