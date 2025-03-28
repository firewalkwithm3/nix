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
  cfg = config.${namespace}.window-manager.clipboard;
in
{
  options.${namespace}.window-manager.clipboard = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable wayland clipboard tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      wtype
    ];
  };
}
