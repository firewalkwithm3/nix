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
  cfg = config.${namespace}.apps.beeper;
in
{
  options.${namespace}.apps.beeper = with types; {
    enable =
      mkBoolOpt config.${namespace}.window-manager.niri.enable
        "Enable beeper - universal chat application";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs.${namespace}; [ beeper ];
  };
}
