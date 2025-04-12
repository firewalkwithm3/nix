{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.services.jellyfin;
  dataDir = config.services.jellyfin.dataDir;
in
{
  options.${namespace}.services.jellyfin = with types; {
    enable = mkBoolOpt false "Enable jellyfin - media server";
    port = mkOpt port 8096 "Port to run on";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    nixpkgs.overlays = [
      (final: prev: {
        jellyfin-web = prev.jellyfin-web.overrideAttrs (
          finalAttrs: previousAttrs: {
            installPhase = ''
              runHook preInstall

              # this is the important line
              sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html

              mkdir -p $out/share
              cp -a dist $out/share/jellyfin-web

              runHook postInstall
            '';
          }
        );
      })
    ];

    services.jellyfin = {
      enable = true;
      group = "media";
    };

    ${namespace} = {
      backups.modules.jellyfin = {
        directories = [ dataDir ];
        databases = [
          "${dataDir}/data/jellyfin.db"
          "${dataDir}/data/library.db"
          "${dataDir}/data/playback_reporting.db"
          "${dataDir}/data/introskipper/introskipper.db"
        ];
      };

      services.caddy.services.jellyfin = {
        port = cfg.port;
        subdomain = "jellyfin";
        domain = "fern.garden";
      };
    };
  };
}
