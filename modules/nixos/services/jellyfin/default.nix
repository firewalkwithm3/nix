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
          {
            name = "jellyfin";
            path = "${dataDir}/data/jellyfin.db";
          }
          {
            name = "jellyfin-library";
            path = "${dataDir}/data/library.db";
          }
          {
            name = "jellyfin-playback-reporting";
            path = "${dataDir}/data/playback_reporting.db";
          }
          {
            name = "jellyfin-introskipper";
            path = "${dataDir}/data/introskipper/introskipper.db";
          }
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
