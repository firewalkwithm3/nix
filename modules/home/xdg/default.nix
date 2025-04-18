{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.window-manager.xdg;
in
{
  options.${namespace}.window-manager.xdg = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable xdg config";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      xdg.mimeApps = {
        enable = true;
      };
    }

    (mkIf config.${namespace}.apps.imv.enable {
      xdg.mimeApps.defaultApplications = {
        "image/jpg" = [ "imv.desktop" ];
        "image/png" = [ "imv.desktop" ];
      };
    })
  ]);
}
