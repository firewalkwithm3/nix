{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.glabels;
in
{
  options.${namespace}.apps.glabels = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable glabels - label creator";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      glabels-qt
    ];
  };
}
