{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.bundles.window-manager;
in
{
  options.${namespace}.bundles.window-manager = with types; {
    enable = mkBoolOpt false "Enable Niri window manager and supporting config";
  };

  config = mkIf cfg.enable {
    ${namespace}.window-manager = {
      clipboard = enabled;
      fuzzel = enabled;
      mako = enabled;
      niri = enabled;
      swayidle = enabled;
      udiskie = enabled;
      waybar = enabled;
      wlsunset = enabled;
      xdg = enabled;
    };
  };
}
