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
  cfg = config.${namespace}.apps.signal;
in
{
  options.${namespace}.apps.signal = with types; {
    enable = mkBoolOpt config.${namespace}.window-manager.niri.enable "Enable signal - encrypted messenger";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      signal-desktop
    ];
  };
}
