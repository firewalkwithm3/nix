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
  cfg = config.${namespace}.window-manager.gtklock;
in
{
  options.${namespace}.window-manager.gtklock = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable gtklock - lock screen";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gtklock
    ];
  };
}
