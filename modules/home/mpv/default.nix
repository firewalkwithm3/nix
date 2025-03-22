{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.mpv;
in
{
  options.${namespace}.apps.mpv = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable mpv - video player";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.mpv = {
        enable = true;
        config = {
          hwdec = "auto-safe";
          vo = "gpu";
          profile = "gpu-hq";
          gpu-context = "wayland";
          geometry = "80%";
          volume-max = 100;
          sub-use-margins = false;
          sub-font-size = 30;
          sub-back-color = "0.0/0.0/0.0";
          sub-color = "1.0/1.0/1.0";
        };
        bindings = {
          "Shift+g" = "add sub-scale +0.1";
          "Shift+f" = "add sub-scale -0.1";
          "Alt+-" = "add video-zoom -0.01";
          "Alt+=" = "add video-zoom +0.01";
        };
      };
    }
    (mkIf config.${namespace}.apps.nextcloud.enable {
      programs.mpv.config.screenshot-directory = "${config.home.homeDirectory}/Nextcloud/Pictures/Screenshots/mpv";
    })
  ]);
}
