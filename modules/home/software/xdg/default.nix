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
    enable = mkBoolOpt false "Enable xdg config";
  };

  config = mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image/jpg" = [ "imv.desktop" ];
        "image/png" = [ "imv.desktop" ];
      };
    };
  };
}
