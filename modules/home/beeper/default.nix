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
  cfg = config.${namespace}.beeper;
in
{
  options.${namespace}.beeper = with types; {
    enable =
      mkBoolOpt config.${namespace}.window-manager.niri.enable
        "Enable beeper - universal chat application";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs.${namespace}; [ beeper ];
  };
}
