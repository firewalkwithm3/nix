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
    enable = mkBoolOpt false "Enable navidrome";
    port = mkOpt port 4533 "Port to run on";
  };

  config = mkIf cfg.enable {
    age.secrets.navidrome.rekeyFile = (inputs.self + "/secrets/services/navidrome.age");

    systemd.services.navidrome.serviceConfig.EnvironmentFile = [
      config.age.secrets.navidrome.path
    ];

    services.navidrome = {
      enable = true;
      settings = {
        Address = "127.0.0.1";
        port = cfg.port;
        ReverseProxyWhitelist = "0.0.0.0/0";
        ReverseProxyUserHeader = "X-authentik-username";
        EnableUserEditing = false;
        MusicFolder = "/mnt/volume2/media/beets";
      };
      group = "media";
    };

    ${namespace}.services.caddy.services.navidrome = {
      port = config.${namespace}.services.authentik.port;
      subdomain = "music";
      domain = "fern.garden";
    };
  };
}
